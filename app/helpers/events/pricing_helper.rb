module Events
  module PricingHelper
    def event_price_badge_classes(event)
      return "is-free" if event.free?
      return "is-ticketed" if event.imported? && event_real_ticket_link?(event)

      "is-standard"
    end

    def event_card_price_text(event)
      return event_price_text(event) if event.free?
      return "Biletli" if event.imported? && event_real_ticket_link?(event)
      return event_price_text(event) unless event.imported?

      nil
    end

    def event_price_text(event, precision: 0, free_label: I18n.t("ui.free"))
      return free_label if event.free?
      return "Biletli Etkinlik" if event.imported? && event_real_ticket_link?(event)
      return "Bilet bilgisi kaynakta" if event.imported? && event_source_link_url(event).present?
      return "Bilet bilgisi dış kaynakta" if event.imported?

      number_to_currency(event.price, unit: "₺", precision: precision)
    end

    def event_real_ticket_link?(event)
      event.ticket_url.present? && Event.ticket_kind_linkable?(event_ticket_url_kind(event))
    end

    def event_source_link_url(event)
      return event.external_url if event.external_url.present?
      return event.ticket_url if %w[etkinlik_detail source detail].include?(event_ticket_url_kind(event))

      nil
    end

    def event_external_action_url(event)
      return event.ticket_url if event_real_ticket_link?(event)

      event_source_link_url(event)
    end

    def event_external_action_label(event)
      event_real_ticket_link?(event) ? "Bilet Al" : "Etkinlik Detayı"
    end

    def event_registration_label(event)
      return "Bilet Al" if event_real_ticket_link?(event)
      return "Etkinlik Detayı" if event_source_link_url(event).present?
      return "Bilet bilgisi dış kaynakta" if event.imported?

      "Kaynak bağlantısı yok"
    end

    def event_ticket_help_text(event)
      return "Ücretsiz katılım." if event.free?
      return "Bilet satışı dış kaynak üzerinden yapılır." if event_real_ticket_link?(event)
      return "Bilet ve detay bilgileri kaynak sayfada güncellenebilir." if event_source_link_url(event).present?

      "Bilet bilgisi dış kaynakta."
    end

    def event_source_attribution_text(event)
      return "Etkinlik.io üzerinden sağlandı" if event.external_source == ExternalEventCandidate::SOURCE_ETKINLIK_IO

      "Dış kaynak üzerinden sağlandı"
    end

  private

    def event_ticket_url_kind(event)
      kind = event.ticket_url_kind.to_s
      return kind if kind.present?
      return Event.classify_ticket_url(event.ticket_url, event.external_url) if event.ticket_url.present?

      "unknown"
    end

  end
end
