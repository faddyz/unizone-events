module EtkinlikIo
  class Scanner
    DEFAULT_BATCH_SIZE = 100
    DEFAULT_MAX_SCAN_LIMIT = 3000

    attr_reader :client, :params, :save

    def initialize(params = {}, client: Client.new, save: false)
      @params = params.to_h
      @client = client
      @save = save
    end

    def call
      import_run = ImportRun.create!(
        source: Catalog::SOURCE,
        dry_run: !save,
        started_at: Time.current,
        parameters: normalized_parameters
      )

      stats = scan(import_run)
      import_run.finish!(stats)
      import_run
    rescue StandardError => error
      import_run&.fail!(error.message)
      raise
    end

    private

    def scan(import_run)
      stats = empty_stats

      selected_city_ids.each do |city_id|
        skip = 0
        loop do
          break if stats[:fetched_count] >= max_scan_limit

          response = client.events(request_params(city_id, skip))
          items = Array(response["items"])
          break if items.blank?

          items.each do |payload|
            break if stats[:fetched_count] >= max_scan_limit

            stats[:fetched_count] += 1
            mapped = Mapper.new(payload, include_low_priority: include_low_priority?).call
            next stats[:skipped_count] += 1 if venue_type_filter.present? && mapped[:venue_type] != venue_type_filter

            mapped[:duplicate_warning] = duplicate_warning(mapped)
            if mapped[:status] == "hidden"
              stats[:hidden_count] += 1
            elsif mapped[:review_reasons].present?
              stats[:skipped_count] += 1
            end

            persist_candidate(mapped, stats) if save
          rescue StandardError
            stats[:failed_count] += 1
          end

          break if items.size < batch_size

          skip += batch_size
        end
      end

      stats
    end

    def persist_candidate(mapped, stats)
      candidate = ExternalEventCandidate.find_or_initialize_by(
        source: mapped.fetch(:source),
        external_id: mapped.fetch(:external_id)
      )
      new_record = candidate.new_record?
      stats[:duplicate_count] += 1 unless new_record
      stats[:new_candidate_count] += 1 if new_record

      status = next_status(candidate, mapped[:status])
      candidate.assign_attributes(mapped.except(:status))
      candidate.status = status
      candidate.first_seen_at ||= Time.current
      candidate.last_seen_at = Time.current
      candidate.save!
    end

    def next_status(candidate, mapped_status)
      return mapped_status if candidate.new_record?
      return candidate.status if candidate.approved? || candidate.rejected? || candidate.skipped?
      return "pending" if candidate.hidden? && mapped_status == "pending"

      mapped_status
    end

    def duplicate_warning(mapped)
      title = mapped[:title].to_s.downcase.squish
      return if title.blank? || mapped[:starts_at].blank?

      range = mapped[:starts_at].beginning_of_day..mapped[:starts_at].end_of_day
      public_duplicate = Event.where(city: mapped[:city], date: range).where("LOWER(title) = ?", title).exists?
      candidate_duplicate = ExternalEventCandidate.where(city: mapped[:city], starts_at: range).where("LOWER(title) = ?", title).where.not(source: mapped[:source], external_id: mapped[:external_id]).exists?

      "Benzer başlık/şehir/tarih bulundu" if public_duplicate || candidate_duplicate
    end

    def request_params(city_id, skip)
      {
        city_ids: city_id,
        start_gte: start_gte,
        end_lte: end_lte,
        skip: skip,
        take: batch_size,
        format_ids: selected_format_ids.presence&.join(","),
        category_ids: selected_category_ids.presence&.join(",")
      }.compact_blank
    end

    def normalized_parameters
      {
        "city_slugs" => selected_city_slugs,
        "format_ids" => selected_format_ids,
        "category_ids" => selected_category_ids,
        "start_gte" => start_gte,
        "end_lte" => end_lte,
        "venue_type" => venue_type_filter,
        "batch_size" => batch_size,
        "max_scan_limit" => max_scan_limit,
        "include_low_priority" => include_low_priority?
      }
    end

    def empty_stats
      {
        fetched_count: 0,
        new_candidate_count: 0,
        duplicate_count: 0,
        skipped_count: 0,
        hidden_count: 0,
        failed_count: 0
      }
    end

    def selected_city_ids
      city_ids = selected_city_slugs.filter_map { |slug| city_id_lookup[slug] }
      raise Client::Error, "No selected cities could be resolved from /cities" if city_ids.blank?

      city_ids
    end

    def selected_city_slugs
      slugs = Array(params[:city_slugs] || params["city_slugs"]).reject(&:blank?)
      slugs.presence || Catalog::DEFAULT_CITY_SLUGS
    end

    def city_id_lookup
      @city_id_lookup ||= catalog_rows(client.cities).each_with_object({}) do |city, lookup|
        id = city["id"]
        next if id.blank?

        slug = city["slug"].presence || city["name"].to_s.parameterize
        lookup[slug] = id
        lookup[city["name"].to_s.parameterize] = id if city["name"].present?
      end
    end

    def catalog_rows(response)
      return response if response.is_a?(Array)
      return Array(response["items"] || response["data"] || response["cities"] || response["results"]) if response.is_a?(Hash)

      []
    end

    def selected_format_ids
      values = Array(params[:format_ids] || params["format_ids"]).reject(&:blank?).map(&:to_i)
      values.presence || Catalog::PRIORITY_FORMAT_IDS
    end

    def selected_category_ids
      Array(params[:category_ids] || params["category_ids"]).reject(&:blank?).map(&:to_i)
    end

    def venue_type_filter
      value = params[:venue_type].presence || params["venue_type"].presence
      %w[VENUE MANUEL ONLINE].include?(value) ? value : nil
    end

    def include_low_priority?
      ActiveModel::Type::Boolean.new.cast(params[:include_low_priority] || params["include_low_priority"])
    end

    def batch_size
      raw = params[:batch_size].presence || params["batch_size"].presence
      return DEFAULT_BATCH_SIZE if raw.blank?

      [ [ raw.to_i, 1 ].max, 100 ].min
    end

    def max_scan_limit
      raw = params[:max_scan_limit].presence || params["max_scan_limit"].presence
      return DEFAULT_MAX_SCAN_LIMIT if raw.blank?

      [ [ raw.to_i, 1 ].max, 3_000 ].min
    end

    def start_gte
      date = parse_date(params[:start_date] || params["start_date"]) || Time.zone.today
      date.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
    end

    def end_lte
      date = parse_date(params[:end_date] || params["end_date"]) || 45.days.from_now.to_date
      date.end_of_day.strftime("%Y-%m-%d %H:%M:%S")
    end

    def parse_date(value)
      Date.parse(value.to_s) if value.present?
    rescue ArgumentError
      nil
    end
  end
end
