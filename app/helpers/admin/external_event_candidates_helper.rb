module Admin::ExternalEventCandidatesHelper
  CANDIDATE_STATUS_LABELS = {
    "pending" => "Bekliyor",
    "approved" => "Yayında",
    "rejected" => "Reddedildi",
    "skipped" => "Geçildi",
    "hidden" => "Gizli",
    "expired" => "Süresi Geçmiş"
  }.freeze

  CANDIDATE_TICKET_KIND_LABELS = {
    "external_ticket" => "Bilet linki",
    "ticket" => "Bilet linki",
    "redirect_ticket" => "Bilet yönlendirme",
    "etkinlik_detail" => "Kaynak detayı",
    "source" => "Kaynak detayı",
    "detail" => "Kaynak detayı",
    "unknown" => "Bilinmiyor"
  }.freeze

  STATUS_SUMMARY_TONES = {
    "pending" => "amber",
    "approved" => "green",
    "skipped" => "blue",
    "rejected" => "red",
    "hidden" => "stone",
    "expired" => "zinc"
  }.freeze

  def candidate_status_label(candidate)
    CANDIDATE_STATUS_LABELS.fetch(candidate.status, candidate.status.to_s.humanize)
  end

  def candidate_summary_tone(status)
    STATUS_SUMMARY_TONES.fetch(status.to_s, "stone")
  end

  def admin_relative_time(value)
    return "-" if value.blank?

    seconds = (Time.current - value).to_i.abs
    return "az önce" if seconds < 60

    minutes = seconds / 60
    return "#{minutes} dakika önce" if minutes < 60

    hours = minutes / 60
    return "#{hours} saat önce" if hours < 24

    days = hours / 24
    "#{days} gün önce"
  end

  def candidate_display_title(candidate)
    plain_display_text(candidate.title.presence || candidate.mapped_data["title"].presence || "Başlıksız aday")
  end

  def candidate_description_snippet(candidate, length: 130)
    text = candidate.mapped_data["description"].presence || candidate.raw_data["content"].presence
    truncate(EtkinlikIo::TextCleaner.plain_text(text), length: length)
  end

  def candidate_short_location(candidate)
    return "Çevrimiçi" if candidate.venue_type == "ONLINE"

    short_location_text(candidate.venue, candidate.city)
  end

  def candidate_city_label(candidate)
    candidate.venue_type == "ONLINE" ? "Online" : candidate.city.presence || "Şehir eksik"
  end

  def candidate_ticket_kind_label(candidate)
    CANDIDATE_TICKET_KIND_LABELS.fetch(candidate.ticket_url_kind.to_s, "Bilinmiyor")
  end

  def candidate_price_label(candidate)
    return "Ücretsiz" if ActiveModel::Type::Boolean.new.cast(candidate.mapped_data["external_is_free"])
    return "Biletli Etkinlik" if candidate.real_ticket_url?
    return "Kaynak bilgisi var" if candidate.source_url.present?

    "Bilet bilgisi dış kaynakta"
  end

  def candidate_source_action_label(candidate)
    candidate.real_ticket_url? ? "Bilet Al" : "Etkinlik Detayı"
  end

  def candidate_source_action_url(candidate)
    candidate.real_ticket_url? ? candidate.ticket_url : candidate.source_url
  end

  def candidate_incomplete?(candidate)
    candidate.review_reasons.present? ||
      candidate.title.blank? ||
      candidate.starts_at.blank? ||
      candidate.category.blank? ||
      (candidate.venue.blank? && candidate.venue_type != "ONLINE")
  end

  def candidate_warning_badges(candidate)
    badges = []
    badges << [ "poster yok", "warning" ] if candidate.poster_url.blank?
    badges << [ "bilet yok", "muted" ] unless candidate.real_ticket_url?
    badges << [ "duplicate", "danger" ] if candidate.duplicate_warning.present?
    badges << [ "düşük öncelik", "danger" ] if candidate.category.in?(%w[theater family community]) || candidate.hidden_reason == "low_priority_category"
    badges << [ "online", "info" ] if candidate.venue_type == "ONLINE"
    badges << [ "eksik", "danger" ] if candidate_incomplete?(candidate)
    badges << [ "süresi geçmiş", "muted" ] if candidate.expired_by_clock?
    badges
  end
end
