require "cgi"

module EventsHelper
  CATEGORY_BADGE_COLORS = {
    "music" => "bg-fuchsia-700 text-fuchsia-100",
    "festival" => "bg-orange-500 text-white",
    "art_exhibition" => "bg-violet-700 text-violet-100",
    "conference" => "bg-blue-700 text-blue-100",
    "workshop" => "bg-teal-500 text-stone-950",
    "networking" => "bg-emerald-600 text-white",
    "technology" => "bg-[#1a3a6b] text-[#c8e6ff]",
    "education" => "bg-cyan-600 text-white",
    "business" => "bg-slate-900 text-white",
    "career" => "bg-amber-600 text-white",
    "food_lifestyle" => "bg-lime-600 text-white",
    "nightlife" => "bg-pink-600 text-white",
    "sports_wellness" => "bg-lime-500 text-stone-950",
    "theater" => "bg-rose-700 text-rose-100",
    "family" => "bg-sky-600 text-white",
    "community" => "bg-stone-900 text-white"
  }.freeze

  CATEGORY_POSTER_BACKGROUNDS = {
    "music" => "from-fuchsia-800 via-pink-600 to-ember",
    "festival" => "from-orange-600 via-pink-600 to-citron",
    "art_exhibition" => "from-violet-900 via-[#2b174d] to-[#d8c0ff]",
    "conference" => "from-blue-900 via-blue-700 to-[#c8e6ff]",
    "workshop" => "from-teal-600 via-cyan-500 to-stone-950",
    "networking" => "from-emerald-700 via-teal-500 to-stone-950",
    "technology" => "from-[#1a3a6b] via-cyan-600 to-[#c8e6ff]",
    "education" => "from-cyan-700 via-blue-700 to-stone-950",
    "business" => "from-stone-950 via-slate-700 to-citron",
    "career" => "from-amber-700 via-orange-500 to-stone-950",
    "food_lifestyle" => "from-lime-700 via-emerald-500 to-stone-950",
    "nightlife" => "from-pink-700 via-rose-600 to-orange-400",
    "sports_wellness" => "from-lime-500 via-emerald-500 to-stone-950",
    "theater" => "from-rose-900 via-stone-950 to-ember",
    "family" => "from-sky-700 via-cyan-500 to-citron",
    "community" => "from-stone-950 via-stone-800 to-citron"
  }.freeze

  STATUS_BADGE_COLORS = {
    "draft" => "bg-stone-100 text-stone-700 ring-1 ring-stone-200",
    "submitted" => "bg-amber-100 text-amber-800 ring-1 ring-amber-200",
    "published" => "bg-emerald-100 text-emerald-800 ring-1 ring-emerald-200",
    "rejected" => "bg-rose-100 text-rose-800 ring-1 ring-rose-200",
    "cancelled" => "bg-zinc-200 text-zinc-700 ring-1 ring-zinc-300"
  }.freeze

  RSVP_BADGE_COLORS = {
    "going" => "bg-emerald-100 text-emerald-800 ring-1 ring-emerald-200",
    "interested" => "bg-blue-100 text-blue-800 ring-1 ring-blue-200",
    "not_going" => "bg-stone-100 text-stone-600 ring-1 ring-stone-200"
  }.freeze

  EVENT_IMAGE_DIMENSIONS = Event::IMAGE_VARIANT_DIMENSIONS
  EVENT_IMAGE_PROXY_EXPIRES_IN = nil
  EVENT_IMAGE_PLACEHOLDER_SRC = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="

  CATEGORY_ICONS = {
    "music" => "music",
    "festival" => "sparkles",
    "art_exhibition" => "image",
    "conference" => "calendar",
    "workshop" => "edit",
    "networking" => "users",
    "technology" => "cpu",
    "education" => "book_open",
    "business" => "users",
    "career" => "check_circle",
    "food_lifestyle" => "ticket",
    "nightlife" => "mic",
    "sports_wellness" => "dumbbell",
    "theater" => "theater",
    "family" => "sparkles",
    "community" => "sparkles"
  }.freeze

  CATEGORY_SIGNAL_COPY = {
    "art_exhibition" => "Görsel kültür, üretim ve ilham odağı yüksek; keşfetmek için sakin ama güçlü bir seçenek.",
    "business" => "İş, girişim ve sektör bağlantıları için net bir profesyonel buluşma alanı.",
    "career" => "Kariyer rotanı netleştirmek ve yeni fırsatlarla temas etmek için pratik bir durak.",
    "food_lifestyle" => "Yemek, üretim ve yaşam tarzı çevresinde sosyal ve hafif bir keşif planı.",
    "nightlife" => "Sosyalleşmek, müzikle açılmak ve geceyi hareketlendirmek isteyenlere yakın duruyor.",
    "sports_wellness" => "Hareket, sağlık ve ekip enerjisi arayanlar için temposu yüksek bir plan.",
    "family" => "Aile ve çocuk odaklı daha yumuşak, birlikte zaman geçirmeye açık bir plan.",
    "community" => "Rahat bir buluşma alanı; yeni insanlarla tanışmak ve şehrin gündemine karışmak için uygun.",
    "general" => "Rahat bir buluşma alanı; yeni insanlarla tanışmak ve şehrin gündemine karışmak için uygun.",
    "technology" => "Ürün, yazılım ve girişim ekosistemine yakınsan gündem yakalamak için güçlü bir durak.",
    "music" => "Canlı atmosfer, sahne enerjisi ve birlikte dinleme hissi arayanlar için öne çıkıyor.",
    "art" => "Görsel kültür, üretim ve ilham odağı yüksek; keşfetmek için sakin ama güçlü bir seçenek.",
    "sports" => "Hareket, rekabet ve ekip enerjisi arayanlar için temposu yüksek bir plan.",
    "education" => "Yeni bir konuya odaklanmak, pratik bilgi almak ve çevreni genişletmek için iyi bir fırsat.",
    "concert" => "Sahne deneyimi merkezde; performansı yerinde yaşamak isteyenler için doğrudan bir seçim.",
    "festival" => "Birden fazla deneyimi aynı güne sığdıran, keşif alanı geniş bir etkinlik.",
    "workshop" => "Dinlemekten fazlasını isteyenler için uygulama, üretim ve katılım alanı sunuyor.",
    "party" => "Sosyalleşmek, müzikle açılmak ve geceyi hareketlendirmek isteyenlere yakın duruyor.",
    "theater" => "Sahne, hikaye ve performans odağıyla daha dikkatli izleme isteyen bir deneyim.",
    "exhibition" => "Gezerek, durup bakarak ve sohbet ederek keşfedilecek kültür odaklı bir rota.",
    "conference" => "Program, konuşmacı ve bağlantı değeriyle ajandana net bir profesyonel kazanım ekler.",
    "networking" => "Yeni bağlantılar kurmak ve aynı ilgi alanındaki insanlarla tanışmak için tasarlanmış."
  }.freeze

  def event_category_badge_classes(event_or_category, *_args, **_kwargs)
    key = event_category_key(event_or_category)
    "inline-flex items-center rounded-full px-3 py-1 font-body text-[0.65rem] font-black uppercase tracking-[0.08em] #{CATEGORY_BADGE_COLORS.fetch(key, CATEGORY_BADGE_COLORS["community"])}"
  end

  def event_poster_background_classes(event_or_category)
    key = event_category_key(event_or_category)
    "bg-gradient-to-br #{CATEGORY_POSTER_BACKGROUNDS.fetch(key, CATEGORY_POSTER_BACKGROUNDS["community"])}"
  end

  def event_category_title(event_or_category)
    key = event_category_key(event_or_category)
    I18n.t("categories.#{key}", default: key.to_s.humanize)
  end

  def event_category_icon(event_or_category)
    key = event_category_key(event_or_category)
    CATEGORY_ICONS.fetch(key, CATEGORY_ICONS["community"])
  end

  def event_category_signal_copy(event_or_category)
    key = event_category_key(event_or_category)
    CATEGORY_SIGNAL_COPY.fetch(key, "Etkinliğin konusu, zamanı ve katılım bilgileri karar vermek için yeterince net görünüyor.")
  end

  def event_category_tone_class(event_or_category)
    "is-#{event_category_key(event_or_category).tr("_", "-")}"
  end

  def event_status_badge_classes(event)
    "inline-flex items-center rounded-full px-3 py-1 text-xs font-bold #{STATUS_BADGE_COLORS.fetch(event.status, STATUS_BADGE_COLORS["draft"])}"
  end

  def event_status_label(event)
    I18n.t("statuses.#{event.status}", default: event.status.humanize)
  end

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

  def event_place_text(event)
    short_location_text(event.location, event.city)
  end

  def event_card_venue_text(event)
    location = plain_display_text(event.location)
    return event_place_text(event) if location.blank?
    return "Çevrimiçi" if location.casecmp("online").zero? || location.casecmp("çevrimiçi").zero?

    parts = location.split(",").map(&:squish).reject(&:blank?)
    [ parts.first || location, parts.second ].compact_blank.uniq.join(", ")
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

  def event_has_poster?(event)
    event.remote_poster_url.present? || event.image.attached?
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

  def attendance_status_badge_classes(status)
    "inline-flex items-center rounded-full px-3 py-1 text-xs font-bold #{RSVP_BADGE_COLORS.fetch(status.to_s, RSVP_BADGE_COLORS["going"])}"
  end

  def attendance_status_label(status)
    I18n.t("rsvps.#{status}", default: status.to_s.humanize)
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

  def event_image_options(variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil)
    width, height = EVENT_IMAGE_DIMENSIONS.fetch(variant)
    {
      alt: alt,
      class: class_name.presence,
      loading: loading,
      decoding: "async",
      width: width,
      height: height,
      sizes: sizes || "#{width}px",
      fetchpriority: fetchpriority,
      data: data,
      aria: aria
    }.compact
  end

  def event_image_tag(event, variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil, defer_src: false)
    return unless event.image.attached?

    source = event_image_source(event.image, variant)
    data_options = event_image_data(event.image, data)
    data_options = event_deferred_image_data(data_options, source) if defer_src

    image_tag(
      defer_src ? EVENT_IMAGE_PLACEHOLDER_SRC : source,
      event_image_options(
        variant,
        alt: alt,
        class_name: class_name,
        loading: loading,
        sizes: sizes,
        fetchpriority: fetchpriority,
        data: data_options,
        aria: aria
      )
    )
  end

  def event_poster_image_tag(event, variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil, defer_src: false)
    if event.remote_poster_url.present?
      options = event_image_options(
        variant,
        alt: alt,
        class_name: class_name,
        loading: loading,
        sizes: sizes,
        fetchpriority: fetchpriority,
        data: defer_src ? event_deferred_image_data(data || {}, event.remote_poster_url) : data,
        aria: aria
      )

      return image_tag(defer_src ? EVENT_IMAGE_PLACEHOLDER_SRC : event.remote_poster_url, options)
    end

    event_image_tag(
      event,
      variant,
      alt: alt,
      class_name: class_name,
      loading: loading,
      sizes: sizes,
      fetchpriority: fetchpriority,
      data: data,
      aria: aria,
      defer_src: defer_src
    )
  end

  def event_card_image_sizes(featured: false, compact: false)
    if featured
      "(min-width: 1024px) 34rem, 88vw"
    elsif compact
      "(min-width: 1024px) 16rem, 88vw"
    else
      "(min-width: 1280px) 25vw, (min-width: 640px) 50vw, 92vw"
    end
  end

  def event_lifecycle_hint(event)
    case event.status
    when "draft"
      I18n.t("lifecycle.draft")
    when "submitted"
      I18n.t("lifecycle.submitted")
    when "published"
      I18n.t("lifecycle.published")
    when "rejected"
      event.review_note.presence || I18n.t("lifecycle.rejected")
    when "cancelled"
      I18n.t("lifecycle.cancelled")
    else
      I18n.t("lifecycle.unknown")
    end
  end

  def event_lifecycle_step(event)
    Event.statuses.keys.index(event.status).to_i + 1
  end

  def event_lifecycle_statuses(event)
    statuses = %w[draft submitted]
    statuses << event.status if event.rejected? || event.cancelled?
    statuses << "published"
    statuses
  end

  def event_lifecycle_completed?(event, status)
    case event.status
    when "draft"
      status == "draft"
    when "submitted"
      %w[draft submitted].include?(status)
    when "published"
      %w[draft submitted published].include?(status)
    when "rejected", "cancelled"
      %w[draft submitted].include?(status) || status == event.status
    else
      status == event.status
    end
  end

  def event_form_field_error?(model, attribute)
    model.errors[attribute].any?
  end

  def event_form_field_error_id(attribute)
    "event-#{attribute.to_s.tr("_", "-")}-error"
  end

  def event_form_field_error_message(model, attribute)
    model.errors.full_messages_for(attribute).to_sentence
  end

  def event_form_control_classes(model, attribute, base: "event-form-control")
    class_names(base, "is-invalid": event_form_field_error?(model, attribute))
  end

  def event_form_aria(model, attribute, describedby: nil)
    ids = [ describedby ]
    invalid = event_form_field_error?(model, attribute)
    ids << event_form_field_error_id(attribute) if invalid

    {
      invalid: invalid ? "true" : "false",
      describedby: ids.compact_blank.join(" ").presence
    }.compact
  end

  def explore_filter_params_with(overrides = {})
    next_params = request.query_parameters.slice(
      "query",
      "city",
      "category",
      "date",
      "date_filter",
      "start_date",
      "end_date",
      "time_filter",
      "price_filter",
      "availability_filter",
      "registration_filter",
      "hide_started",
      "sort_by",
      "view"
    )

    overrides.each do |key, value|
      key = key.to_s
      if value.blank?
        next_params.delete(key)
      else
        next_params[key] = value
      end
    end

    next_params
  end

  def explore_events_progress_text(events)
    total_count = events.total_count.to_i
    shown_count = [ events.current_page.to_i * events.limit_value.to_i, total_count ].min

    if shown_count >= total_count
      "#{total_count} etkinliğin tamamı gösteriliyor"
    else
      "1–#{shown_count} / #{total_count} etkinlik gösteriliyor"
    end
  end

  def explore_filter_remove_params(filter)
    next_params = explore_filter_params_with
    key = filter[:key].to_s

    if key == "category" && next_params["category"].is_a?(Array)
      categories = next_params["category"].reject { |category| category.to_s == filter[:value].to_s }
      categories.any? ? next_params["category"] = categories : next_params.delete("category")
    else
      next_params.delete(key)
    end

    next_params
  end

  private

  def event_category_key(event_or_category)
    event_or_category.respond_to?(:category) ? event_or_category.category.to_s : event_or_category.to_s
  end

  def event_ticket_url_kind(event)
    kind = event.ticket_url_kind.to_s
    return kind if kind.present?
    return Event.classify_ticket_url(event.ticket_url, event.external_url) if event.ticket_url.present?

    "unknown"
  end

  def prepared_event_attendance_counts
    @event_attendance_counts || {}
  end

  def prepared_event_attendee_previews
    @event_attendee_previews || {}
  end

  def event_image_source(image, variant)
    return rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN) unless image.variable?

    representation = image.variant(Event::IMAGE_VARIANTS.fetch(variant))

    rails_storage_proxy_path(
      representation,
      expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN
    )
  rescue StandardError => error
    Rails.logger.warn("Falling back to original event image after variant URL failure: #{error.class}: #{error.message}")
    rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN)
  end

  def event_image_data(image, data)
    merged = (data || {}).dup
    merged[:controller] = [ merged[:controller], "image-fallback" ].compact_blank.join(" ")
    merged[:action] = [ merged[:action], "error->image-fallback#recover" ].compact_blank.join(" ")
    merged[:image_fallback_src_value] = rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN)
    merged
  end

  def event_deferred_image_data(data, source)
    data = data.dup
    data[:poster_lightbox_target] = [ data[:poster_lightbox_target], "image" ].compact_blank.join(" ")
    data[:poster_lightbox_src] = source
    data
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
