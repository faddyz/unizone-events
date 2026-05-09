class EventRanker
  HIGH_PRIORITY_CATEGORIES = %w[
    music
    festival
    technology
    conference
    networking
  ].freeze
  MEDIUM_PRIORITY_CATEGORIES = %w[
    art_exhibition
    culture
    education
    career
    business
  ].freeze

  class << self
    def rank(relation)
      relation
        .select("events.*")
        .select("#{going_count_sql} AS going_score")
        .select("#{interested_count_sql} AS interested_score")
        .select("#{auto_score_sql} AS auto_score")
        .select("#{final_score_sql} AS final_score")
        .select("#{manual_override_sql} AS manual_override_present")
        .select("#{EventCityPriority.score_sql} AS city_priority")
        .reorder(Arel.sql(rank_order_sql))
    end

    private

    def rank_order_sql
      [
        EventCityPriority.order_sql,
        "final_score DESC",
        "manual_override_present DESC",
        "events.date ASC",
        "going_score DESC",
        "interested_score DESC",
        "auto_score DESC",
        "events.published_at DESC",
        "events.id DESC"
      ].join(", ")
    end

    def final_score_sql
      "CASE WHEN events.editor_score IS NULL THEN (#{auto_score_sql}) ELSE events.editor_score END"
    end

    def manual_override_sql
      "CASE WHEN events.editor_score IS NULL THEN 0 ELSE 1 END"
    end

    def auto_score_sql
      [
        data_quality_score_sql,
        date_score_sql,
        category_score_sql,
        logistics_score_sql,
        interest_score_sql
      ].join(" + ")
    end

    def data_quality_score_sql
      <<~SQL.squish
        (
          CASE WHEN events.title IS NOT NULL AND LENGTH(TRIM(events.title)) >= 8 THEN 4 ELSE 0 END +
          CASE
            WHEN events.description IS NOT NULL AND LENGTH(TRIM(events.description)) >= 80 THEN 6
            WHEN events.description IS NOT NULL AND LENGTH(TRIM(events.description)) >= 40 THEN 3
            ELSE 0
          END +
          CASE WHEN events.date IS NOT NULL THEN 3 ELSE 0 END +
          CASE WHEN events.city IS NOT NULL AND TRIM(events.city) <> '' THEN 3 ELSE 0 END +
          CASE WHEN events.location IS NOT NULL AND TRIM(events.location) <> '' THEN 4 ELSE 0 END
        )
      SQL
    end

    def date_score_sql
      <<~SQL.squish
        (
          CASE
            WHEN events.date IS NULL THEN 0
            WHEN events.date < CURRENT_TIMESTAMP THEN 8
            WHEN events.date <= CURRENT_TIMESTAMP + INTERVAL '3 days' THEN 22
            WHEN events.date <= CURRENT_TIMESTAMP + INTERVAL '7 days' THEN 19
            WHEN events.date <= CURRENT_TIMESTAMP + INTERVAL '14 days' THEN 16
            WHEN events.date <= CURRENT_TIMESTAMP + INTERVAL '30 days' THEN 11
            WHEN events.date <= CURRENT_TIMESTAMP + INTERVAL '60 days' THEN 6
            ELSE 2
          END
        )
      SQL
    end

    def category_score_sql
      high = quoted_categories(HIGH_PRIORITY_CATEGORIES)
      medium = quoted_categories(MEDIUM_PRIORITY_CATEGORIES)

      <<~SQL.squish
        (
          CASE
            WHEN events.category IN (#{high}) THEN 18
            WHEN events.category IN (#{medium}) THEN 13
            WHEN events.category = 'community' THEN 8
            ELSE 6
          END
        )
      SQL
    end

    def logistics_score_sql
      <<~SQL.squish
        (
          CASE
            WHEN events.remote_poster_url IS NOT NULL AND TRIM(events.remote_poster_url) <> '' THEN 5
            WHEN EXISTS (
              SELECT 1
              FROM active_storage_attachments event_images
              WHERE event_images.record_type = 'Event'
                AND event_images.record_id = events.id
                AND event_images.name = 'image'
            ) THEN 5
            ELSE 0
          END +
          CASE
            WHEN events.ticket_url IS NOT NULL AND TRIM(events.ticket_url) <> '' THEN 4
            WHEN events.external_url IS NOT NULL AND TRIM(events.external_url) <> '' THEN 4
            WHEN events.capacity IS NOT NULL THEN 3
            ELSE 0
          END +
          CASE WHEN events.location IS NOT NULL AND TRIM(events.location) <> '' THEN 3 ELSE 0 END +
          CASE
            WHEN events.price IS NOT NULL THEN 3
            WHEN events.external_is_free IS NOT NULL THEN 3
            ELSE 0
          END
        )
      SQL
    end

    def interest_score_sql
      "LEAST(25.0, (#{going_count_sql}) * 2.0 + (#{interested_count_sql}) * 0.5)"
    end

    def going_count_sql
      <<~SQL.squish
        (
          SELECT COUNT(*)
          FROM attendances
          WHERE attendances.event_id = events.id
            AND attendances.status = 'going'
        )
      SQL
    end

    def interested_count_sql
      <<~SQL.squish
        (
          SELECT COUNT(*)
          FROM attendances
          WHERE attendances.event_id = events.id
            AND attendances.status = 'interested'
        )
      SQL
    end

    def quoted_categories(categories)
      categories.map { |category| ActiveRecord::Base.connection.quote(category) }.join(", ")
    end
  end
end
