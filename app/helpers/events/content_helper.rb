module Events
  module ContentHelper
    def event_place_text(event)
      short_location_text(event.location, event.city)
    end

    def event_card_venue_text(event)
      event_place_parts(event).first
    end

    def event_card_location_detail_text(event)
      event_place_parts(event).second
    end

    def event_place_parts(event)
      city = plain_display_text(event.city).presence
      location = plain_display_text(event.location).to_s

      if city == "Online" || location.casecmp("online").zero? || location.casecmp("çevrimiçi").zero?
        return [ "Çevrimiçi", (city unless city == "Online") ]
      end

      return [ city || "Konum yakında", nil ] if location.blank?

      parts = location.split(",").map(&:squish).reject(&:blank?)
      primary = parts.first || location
      secondary = [ parts.second, city ].compact_blank.uniq.join(", ").presence

      [ primary, secondary ]
    end

    def event_card_month_label(date)
      l(date, format: "%b")
    end

    def event_card_datetime_label(date)
      l(date, format: "%d %b, %H:%M")
    end

    def event_card_time_label(event)
      return "Şu anda gerçekleşiyor!" if event.ongoing?

      event_card_datetime_label(event.date)
    end

    def event_card_time_classes(event)
      [ "event-card-time", ("is-live" if event.ongoing?) ].compact.join(" ")
    end

    def event_list_time_classes(event)
      [ "explore-list-time", ("is-live" if event.ongoing?) ].compact.join(" ")
    end

    def event_show_datetime_label(event)
      if event.ongoing?
        return safe_join([
          "#{l(event.date, format: :long)} başladı; ",
          tag.span("şu an devam ediyor.", class: "event-live-inline")
        ])
      end

      l(event.date, format: :long)
    end

    def event_crowd_signal_title(event, going_count)
      return "Katılım bilgisi kaynakta" if event.imported? && going_count.to_i.zero?

      "#{going_count} kişi katılıyor!"
    end

    def event_crowd_signal_copy(event, going_count)
      return "Dış kaynak katılım sayısı paylaşmadığı için burada yalnızca Unizone içindeki etkileşim görünür." if event.imported? && going_count.to_i.zero?
      return "Bu etkinlik şimdiden ilgi görmeye başladı." if going_count.to_i.positive?

      "İlk katılanlardan biri olup akışı başlat."
    end

    def event_decision_crowd_signal_label(event, going_count)
      event.imported? && going_count.to_i.zero? ? "Kaynak sinyali" : "Kalabalık"
    end

    def event_decision_crowd_signal_title(event, going_count)
      return "Kaynakta öne çıkan plan" if event.imported? && going_count.to_i.zero?

      "#{going_count} kişi katılıyor!"
    end

    def event_decision_crowd_signal_copy(event, going_count)
      return "Katılım sayısı paylaşılmıyor; mekan, tarih ve kayıt akışı net olduğu için hızlıca değerlendirebilirsin." if event.imported? && going_count.to_i.zero?
      return "Bu etkinlik şimdiden ilgi görmeye başladı." if going_count.to_i.positive?

      "İlk katılanlardan biri olup akışı başlat."
    end

    def event_decision_price_signal_title(event)
      return event_price_text(event) if event.free? || !event.imported?
      return "Biletli" if event_real_ticket_link?(event)
      return "Kaynakta kontrol et" if event_source_link_url(event).present?

      "Bilgi kaynakta"
    end

    def event_decision_price_signal_copy(event)
      return "Ücretsiz katılım; karar vermesi kolay ve erişim bariyeri düşük." if event.free?
      return "Bilet veya kayıt akışı dış kaynakta tamamlanıyor; fiyat ve uygunluk orada netleşir." if event.imported? && event_real_ticket_link?(event)
      return "Güncel fiyat ve katılım koşulları kaynak sayfada değişebilir; gitmeden önce kontrol etmek iyi olur." if event.imported?

      "Katılım ücreti net olarak belirtilmiş; planını buna göre yapabilirsin."
    end

    def event_decision_registration_signal_copy(event, ticket_url)
      return "Ücretsiz katılım adımına kaynak sayfadan devam edebilirsin; gitmeden önce güncel detayları oradan kontrol et." if event.free? && event.imported? && ticket_url.present?
      return "Kararını verdiğinde bilet veya kayıt adımına doğrudan kaynak sayfadan devam edebilirsin." if event.imported? && ticket_url.present?
      return "Detay ve kayıt bilgileri kaynak sayfada güncellenebilir; son kontrolü oradan yapabilirsin." if event.imported?
      return event_ticket_help_text(event) if ticket_url.present?

      "Katılımını buradan bildirebilir, fikrin değişirse seçimini dilediğin an güncelleyebilirsin."
    end

    def short_location_text(location, city)
      city = plain_display_text(city)
      location = plain_display_text(location)
      return "Çevrimiçi" if city == "Online" || location.casecmp("online").zero? || location.casecmp("çevrimiçi").zero?
      return city if location.blank?

      parts = location.split(",").map(&:squish).reject(&:blank?)
      if parts.size >= 2
        district = parts.second
        city_suffix = city.present? && district.exclude?(city) ? ", #{city}" : ""
        return "#{parts.first} · #{district}#{city_suffix}"
      end

      [ parts.first || location, city ].compact_blank.uniq.join(", ")
    end

    def event_display_title(event)
      plain_display_text(event.title)
    end

    def event_description_text(event, preserve_paragraphs: false)
      EtkinlikIo::TextCleaner.plain_text(event.description, preserve_paragraphs: preserve_paragraphs)
    end

    def event_description_snippet(event, length: 150)
      truncate(event_description_text(event), length: length)
    end

    def event_story_segments(event)
      text = event_description_text(event).to_s
      return [] if text.blank?

      normalized = text.gsub(/\r\n?/, "\n").gsub("\u00A0", " ").strip
      lines = normalized.split("\n").map(&:strip).reject(&:blank?)
      line_facts = extract_line_facts(lines)

      if line_facts.size >= 3
        [ { type: :facts, items: line_facts } ]
      else
        normalized.split(/\n{2,}/).map(&:strip).reject(&:blank?).map { |paragraph| { type: :paragraph, text: paragraph } }
      end
    end

    def plain_display_text(value)
      EtkinlikIo::TextCleaner.plain_text(value)
    end

    def event_attendance_count(event)
      prepared_event_attendance_counts.fetch(event.id) { event.attendees_count }.to_i
    end

    def event_going_score(event)
      if event.respond_to?(:has_attribute?) && event.has_attribute?(:going_score)
        event[:going_score].to_i
      else
        event_attendance_count(event)
      end
    end

    def event_attendee_preview(event, limit: 3)
      prepared = prepared_event_attendee_previews[event.id]
      return prepared.first(limit) if prepared

      event.going_users.limit(limit).to_a
    end

  private

    def prepared_event_attendance_counts
      @event_attendance_counts || {}
    end

    def prepared_event_attendee_previews
      @event_attendee_previews || {}
    end

    def extract_line_facts(lines)
      lines.filter_map do |line|
        match = line.match(/\A([A-ZÇĞİÖŞÜ][A-Za-zÇĞİÖŞÜçğıöşü0-9'’().,\- ]{1,32}):\s+(.+)\z/)
        next unless match

        label, value = match.captures
        next if value.split.size < 2
        [ label.strip, value.strip ]
      end
    end

  end
end
