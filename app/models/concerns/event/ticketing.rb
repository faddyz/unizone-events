module Event::Ticketing
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_conversion_fields
  end

  class_methods do
    def classify_ticket_url(ticket_url, _external_url = nil)
      value = ticket_url.to_s.strip
      return "unknown" if value.blank?

      uri = URI.parse(value)
      host = uri.host.to_s.downcase
      return "redirect_ticket" if etkinlik_host?(host) && etkinlik_ticket_redirect_path?(uri.path.to_s)
      return "etkinlik_detail" if etkinlik_host?(host)

      "external_ticket"
    rescue URI::InvalidURIError
      "unknown"
    end

    def ticket_kind_linkable?(kind)
      %w[external_ticket redirect_ticket ticket].include?(kind.to_s)
    end

    def etkinlik_host?(host)
      host == "etkinlik.io" || host.end_with?(".etkinlik.io")
    end

    def etkinlik_ticket_redirect_path?(path)
      path.start_with?("/redirect-ticket-url") ||
        path.match?(%r{\A/api/v\d+/events/[^/]+/ticket-url\z})
    end
  end

  def free?
    if imported?
      return external_is_free? unless external_is_free.nil?
      return price.to_f.zero? if price.present?

      return false
    end

    price.nil? || price.to_f.zero?
  end

  def imported?
    external_source.present?
  end

  private

  def normalize_conversion_fields
    self.ticket_url = ticket_url.to_s.strip.presence
  end
end
