module EtkinlikIo
  class Mapper
    DEFAULT_POSTER_URL_PATTERN = %r{\Ahttps?://[^/]*ifyazilim\.nyc3\.digitaloceanspaces\.com/.*/VarsayilanAfisler/\d+\.(?:jpe?g|png|webp)\z}i
    MUSIC_CATEGORY_SLUGS = %w[
      alternatif-muzik caz-muzik dunya-muzik klasik-muzik ozgun-muzik parti-canli-muzik pop-muzik
      rock-muzik soul-muzik turk-sanat-halk-muzigi
    ].freeze
    LOW_PRIORITY_SLUGS = %w[tiyatro-ve-gosteriler cocuk-tiyatrosu cocuk-gelisimi diger].freeze
    BROAD_EDUCATION_KEYWORDS = %w[
      yapay zeka ai yazilim software kodlama teknoloji girisim startup finans pazarlama
      yonetim liderlik kariyer is networking satis e-ticaret ecommerce veri data
    ].freeze

    attr_reader :payload, :include_low_priority

    def initialize(payload, include_low_priority: false)
      @payload = payload.to_h
      @include_low_priority = include_low_priority
    end

    def call
      mapped = mapped_attributes
      mapped[:status] = hidden?(mapped) ? "hidden" : "pending"
      mapped[:hidden_reason] = hidden_reason(mapped)
      mapped
    end

    private

    def mapped_attributes
      starts_at = parsed_time(payload["start"])
      ends_at = parsed_time(payload["end"])
      venue_type = payload["venue_type"].presence || "VENUE"
      location = location_for(venue_type)
      city = city_for(venue_type)
      category = category_for
      ticket_url = valid_url(payload["ticket_url"])
      external_url = valid_url(payload["url"])

      {
        source: Catalog::SOURCE,
        external_id: payload["id"].to_s,
        title: plain_text(payload["name"]),
        city: city,
        venue: location,
        venue_type: venue_type,
        starts_at: starts_at,
        ends_at: ends_at,
        category: category,
        format: payload.dig("format", "slug").presence || payload.dig("format", "name"),
        poster_url: poster_url,
        ticket_url: ticket_url,
        external_url: external_url,
        ticket_url_kind: ticket_url_kind(ticket_url, external_url),
        raw_data: payload,
        mapped_data: {
          "title" => plain_text(payload["name"]),
          "description" => plain_description,
          "category" => category,
          "city" => city,
          "location" => location,
          "starts_at" => starts_at&.iso8601,
          "ends_at" => ends_at&.iso8601,
          "ticket_url" => ticket_url,
          "external_url" => external_url,
          "external_is_free" => payload["is_free"]
        }.compact,
        review_reasons: review_reasons(starts_at, city, location, category),
        priority: priority_for(category),
        priority_reasons: priority_reasons(category),
        hidden_reason: nil,
        first_seen_at: Time.current,
        last_seen_at: Time.current
      }
    end

    def plain_description
      plain_text(payload["content"], preserve_paragraphs: true)
    end

    def plain_text(value, preserve_paragraphs: false)
      TextCleaner.plain_text(value, preserve_paragraphs: preserve_paragraphs)
    end

    def category_for
      format_slug = payload.dig("format", "slug").to_s
      category_slug = payload.dig("category", "slug").to_s

      return "music" if format_slug == "konser" || MUSIC_CATEGORY_SLUGS.include?(category_slug)
      return "festival" if format_slug == "festival"
      return "art_exhibition" if format_slug == "sergi" || category_slug == "sanat"
      return "conference" if %w[konferans kongre panel seminer sempozyum soylesi zirve].include?(format_slug)
      return "community" if format_slug == "egitim" && category_slug == "diger" && niche_education_topic?
      return "workshop" if %w[atolye calistay egitim].include?(format_slug)
      return "technology" if %w[bilim-teknoloji bilisim uretim-ve-muhendislik].include?(category_slug)
      return "business" if %w[is-dunyasi girisimcilik finans-ekonomi pazarlama yonetim-ve-liderlik].include?(category_slug)
      return "career" if category_slug == "kariyer"
      return "education" if %w[egitim-ogretim kisisel-gelisim yabanci-dil].include?(category_slug)
      return "food_lifestyle" if %w[ascilik-ve-mutfak hobi-yasam-tarzi].include?(category_slug)
      return "sports_wellness" if category_slug == "spor"
      return "family" if %w[cocuk-gelisimi cocuk-tiyatrosu].include?(category_slug)
      return "theater" if category_slug == "tiyatro-ve-gosteriler" || format_slug == "sahne-sanatlari"

      "community"
    end

    def hidden?(mapped)
      hidden_reason(mapped).present?
    end

    def hidden_reason(mapped)
      return "low_priority_category" if !include_low_priority && low_priority?
      return "missing_title" if mapped[:title].blank?
      return "missing_start" if mapped[:starts_at].blank?
      return "missing_location" if mapped[:venue].blank? && mapped[:venue_type] != "ONLINE"

      reference_time = mapped[:ends_at].presence || mapped[:starts_at].presence
      return "expired" if reference_time.present? && reference_time < Time.current

      nil
    end

    def low_priority?
      category = category_for
      return false if category.in?(%w[music festival])

      LOW_PRIORITY_SLUGS.include?(payload.dig("category", "slug").to_s) &&
        category.in?(%w[theater family community workshop])
    end

    def niche_education_topic?
      text = [ payload["name"], payload["content"] ].join(" ").downcase
      BROAD_EDUCATION_KEYWORDS.none? { |keyword| text.include?(keyword) }
    end

    def priority_for(category)
      case category
      when "music", "festival", "conference", "technology", "business"
        90
      when "art_exhibition", "networking", "education", "career"
        70
      when "food_lifestyle", "nightlife", "sports_wellness", "community"
        45
      else
        20
      end
    end

    def priority_reasons(category)
      reasons = []
      reasons << "priority_category" if %w[music festival conference technology business].include?(category)
      reasons << "online_priority_kept" if payload["venue_type"] == "ONLINE" && reasons.any?
      reasons
    end

    def review_reasons(starts_at, city, location, category)
      reasons = []
      reasons << "missing_title" if payload["name"].blank?
      reasons << "missing_start" if starts_at.blank?
      reasons << "missing_city" if city.blank?
      reasons << "missing_location" if location.blank? && payload["venue_type"] != "ONLINE"
      reasons << "missing_category" if category.blank?
      reasons << "missing_poster" if poster_url.blank?
      reasons << "missing_source" if valid_url(payload["url"]).blank? && valid_url(payload["ticket_url"]).blank?
      reasons
    end

    def city_for(venue_type)
      return "Online" if venue_type == "ONLINE"

      venue_data = payload["venue_data"]
      return venue_data.dig("city", "name") if venue_data.is_a?(Hash) && venue_data.dig("city", "name").present?
      return venue_data["city_name"] if venue_data.is_a?(Hash) && venue_data["city_name"].present?
      return payload.dig("venue", "city", "name") if payload.dig("venue", "city", "name").present?

      nil
    end

    def location_for(venue_type)
      return "Çevrimiçi" if venue_type == "ONLINE"

      venue_data = payload["venue_data"]
      if venue_data.is_a?(Hash)
        name = venue_data["name"]
        district = venue_data["district_name"].presence || venue_data.dig("district", "name")
        address = venue_data["address"]
        return [ name, district, address ].compact_blank.uniq.join(", ").presence
      end

      payload.dig("venue", "name").presence || payload.dig("venue", "address").presence
    end

    def ticket_url_kind(ticket_url, external_url)
      Event.classify_ticket_url(ticket_url, external_url)
    end

    def valid_url(value)
      value = value.to_s.strip
      return if value.blank?
      return unless value.match?(Event::VALID_REMOTE_URL)

      value
    end

    def poster_url
      value = valid_url(payload["poster_url"])
      return if value.blank?
      return if default_poster_url?(value)

      value
    end

    def default_poster_url?(value)
      value.to_s.match?(DEFAULT_POSTER_URL_PATTERN)
    end

    def parsed_time(value)
      Time.zone.parse(value.to_s) if value.present?
    rescue ArgumentError
      nil
    end
  end
end
