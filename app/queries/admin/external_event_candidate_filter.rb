class Admin::ExternalEventCandidateFilter
  PRESETS = [
    [ "complete", "Tam Uygun" ],
    [ "new", "Yeni Gelenler" ],
    [ "low_priority", "Dusuk Oncelik" ],
    [ "incomplete", "Eksik Bilgili" ],
    [ "approved", "Yayina Alinan" ],
    [ "skipped", "Gecilen" ],
    [ "rejected", "Reddedilen" ]
  ].freeze

  def self.normalize_preset(value)
    PRESETS.map(&:first).include?(value.to_s) ? value.to_s : "complete"
  end

  attr_reader :scope, :preset, :query, :last_run

  def initialize(scope:, preset:, query:, last_run: nil)
    @scope = scope
    @preset = preset.to_s
    @query = query.to_s.strip
    @last_run = last_run
  end

  def results
    relation = scope.order(priority: :desc, starts_at: :asc, created_at: :desc)
    relation = apply_preset(relation)
    apply_query(relation)
  end

  private

  def apply_query(relation)
    return relation if query.blank?

    needle = "%#{query.downcase}%"
    relation.where("LOWER(title) LIKE :query OR LOWER(venue) LIKE :query OR LOWER(city) LIKE :query", query: needle)
  end

  def apply_preset(relation)
    case preset
    when "complete"
      relation.pending.where.not(category: [ "theater", "family" ])
              .where.not(poster_url: [ nil, "" ])
              .where("starts_at IS NOT NULL AND (city IS NOT NULL OR venue_type = 'ONLINE') AND (venue IS NOT NULL OR venue_type = 'ONLINE') AND (ticket_url IS NOT NULL OR external_url IS NOT NULL)")
              .where("COALESCE(ends_at, starts_at) >= ?", Time.current)
    when "new"
      since = last_run&.started_at || 24.hours.ago
      relation.pending.where("first_seen_at >= ? OR created_at >= ?", since, 24.hours.ago)
    when "low_priority"
      relation.where(status: %w[pending hidden expired])
              .where("category IN (?) OR hidden_reason = ?", %w[theater family community], "low_priority_category")
    when "incomplete"
      relation.pending.where("poster_url IS NULL OR poster_url = '' OR starts_at IS NULL OR category IS NULL OR (venue IS NULL AND venue_type != 'ONLINE') OR (ticket_url IS NULL AND external_url IS NULL)")
    when "approved", "skipped", "rejected"
      relation.where(status: preset)
    else
      relation.pending
    end
  end
end
