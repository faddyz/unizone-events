require "securerandom"

module EtkinlikIo
  class CandidatePublisher
    DEFAULT_IMPORTER_EMAIL = "importer@unizone.local"

    attr_reader :candidate, :attributes

    def initialize(candidate, attributes = {})
      @candidate = candidate
      @attributes = attributes.to_h
    end

    def call
      return candidate.resolved_event if candidate.approved? && candidate.resolved_event.present?

      Event.transaction do
        event = preview_event
        event.publish!

        candidate.update!(
          status: "approved",
          resolved_event: event,
          resolved_at: Time.current,
          hidden_reason: nil
        )
        event
      end
    end

    def preview_event
      Event.find_or_initialize_by(
        external_source: candidate.source,
        external_id: candidate.external_id
      ).tap do |event|
        event.assign_attributes(event_attributes)
      end
    end

    private

    def event_attributes
      mapped = candidate.mapped_data.to_h
      {
        user: importer_user,
        title: plain_text(value_for("title", candidate.title)),
        description: plain_text(value_for("description", mapped["description"]), preserve_paragraphs: true).presence || "Detay bilgisi dış kaynakta güncellenebilir.",
        category: normalized_category(value_for("category", candidate.category)),
        city: normalized_city(value_for("city", candidate.city)),
        location: plain_text(value_for("location", candidate.venue)).presence || "Çevrimiçi",
        date: parsed_time(value_for("starts_at", candidate.starts_at)),
        end_date: parsed_time(value_for("ends_at", candidate.ends_at)),
        price: external_free? ? 0 : nil,
        ticket_url: ticket_url,
        external_url: external_url,
        remote_poster_url: valid_url(candidate.poster_url),
        external_is_free: external_free?,
        ticket_url_kind: Event.classify_ticket_url(ticket_url, external_url),
        external_source: candidate.source,
        external_id: candidate.external_id,
        imported_at: Time.current,
        status: "published"
      }
    end

    def value_for(key, fallback)
      attributes[key].presence || attributes[key.to_sym].presence || fallback
    end

    def external_free?
      raw = attributes["external_is_free"]
      raw = candidate.mapped_data["external_is_free"] if raw.nil?
      ActiveModel::Type::Boolean.new.cast(raw)
    end

    def ticket_url
      @ticket_url ||= valid_url(value_for("ticket_url", candidate.ticket_url))
    end

    def external_url
      @external_url ||= valid_url(value_for("external_url", candidate.external_url))
    end

    def normalized_category(value)
      Event.categories.key?(value.to_s) ? value.to_s : "community"
    end

    def normalized_city(value)
      Event::CITY_OPTIONS.include?(value.to_s) ? value.to_s : "Online"
    end

    def parsed_time(value)
      return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)

      Time.zone.parse(value.to_s) if value.present?
    rescue ArgumentError
      nil
    end

    def valid_url(value)
      value = value.to_s.strip
      return if value.blank?
      return unless value.match?(Event::VALID_REMOTE_URL)

      value
    end

    def plain_text(value, preserve_paragraphs: false)
      TextCleaner.plain_text(value, preserve_paragraphs: preserve_paragraphs)
    end

    def importer_user
      User.find_or_create_by!(email: DEFAULT_IMPORTER_EMAIL) do |user|
        user.name = "Unizone API Importer"
        password = SecureRandom.hex(24)
        user.password = password
        user.password_confirmation = password
      end
    end
  end
end
