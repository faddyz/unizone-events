module EventsHelper
  CATEGORY_BADGE_COLORS = {
    "general" => "bg-stone-900 text-white",
    "technology" => "bg-[#1a3a6b] text-[#c8e6ff]",
    "music" => "bg-fuchsia-700 text-fuchsia-100",
    "art" => "bg-[#3d1060] text-[#b06eff]",
    "sports" => "bg-lime-500 text-stone-950",
    "education" => "bg-cyan-600 text-white",
    "concert" => "bg-indigo-700 text-indigo-100",
    "festival" => "bg-orange-500 text-white",
    "workshop" => "bg-teal-500 text-stone-950",
    "party" => "bg-pink-600 text-white",
    "theater" => "bg-rose-700 text-rose-100",
    "exhibition" => "bg-violet-700 text-violet-100",
    "conference" => "bg-blue-700 text-blue-100",
    "networking" => "bg-emerald-600 text-white"
  }.freeze

  CATEGORY_POSTER_BACKGROUNDS = {
    "general" => "from-stone-950 via-stone-800 to-citron",
    "technology" => "from-[#1a3a6b] via-cyan-600 to-[#c8e6ff]",
    "music" => "from-fuchsia-800 via-pink-600 to-ember",
    "art" => "from-[#3d1060] via-violet-700 to-[#b06eff]",
    "sports" => "from-lime-500 via-emerald-500 to-stone-950",
    "education" => "from-cyan-700 via-blue-700 to-stone-950",
    "concert" => "from-indigo-900 via-indigo-700 to-rose-500",
    "festival" => "from-orange-600 via-pink-600 to-citron",
    "workshop" => "from-teal-600 via-cyan-500 to-stone-950",
    "party" => "from-pink-700 via-rose-600 to-orange-400",
    "theater" => "from-rose-900 via-stone-950 to-ember",
    "exhibition" => "from-violet-900 via-[#2b174d] to-[#d8c0ff]",
    "conference" => "from-blue-900 via-blue-700 to-[#c8e6ff]",
    "networking" => "from-emerald-700 via-teal-500 to-stone-950"
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
  EVENT_IMAGE_PROXY_EXPIRES_IN = 1.year

  CATEGORY_ICONS = {
    "general" => "sparkles",
    "technology" => "cpu",
    "music" => "music",
    "art" => "palette",
    "sports" => "dumbbell",
    "education" => "book_open",
    "concert" => "mic",
    "festival" => "sparkles",
    "workshop" => "edit",
    "party" => "ticket",
    "theater" => "theater",
    "exhibition" => "image",
    "conference" => "calendar",
    "networking" => "users"
  }.freeze

  CATEGORY_SIGNAL_COPY = {
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
    "inline-flex items-center rounded-full px-3 py-1 font-body text-[0.65rem] font-black uppercase tracking-[0.08em] #{CATEGORY_BADGE_COLORS.fetch(key, CATEGORY_BADGE_COLORS["general"])}"
  end

  def event_poster_background_classes(event_or_category)
    key = event_category_key(event_or_category)
    "bg-gradient-to-br #{CATEGORY_POSTER_BACKGROUNDS.fetch(key, CATEGORY_POSTER_BACKGROUNDS["general"])}"
  end

  def event_category_title(event_or_category)
    key = event_category_key(event_or_category)
    I18n.t("categories.#{key}", default: key.to_s.humanize)
  end

  def event_category_icon(event_or_category)
    key = event_category_key(event_or_category)
    CATEGORY_ICONS.fetch(key, CATEGORY_ICONS["general"])
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
    event.free? ? "text-emerald-700" : "text-stone-950"
  end

  def event_price_text(event, precision: 0, free_label: I18n.t("ui.free"))
    return free_label if event.free?

    number_to_currency(event.price, unit: "₺", precision: precision)
  end

  def event_place_text(event)
    [event.location.presence, event.city.presence].compact.join(", ")
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

  def event_image_tag(event, variant, alt:, class_name:, loading: "lazy", sizes: nil, fetchpriority: nil, data: nil, aria: nil)
    return unless event.image.attached?

    image_tag(
      event_image_source(event.image, variant),
      event_image_options(
        variant,
        alt: alt,
        class_name: class_name,
        loading: loading,
        sizes: sizes,
        fetchpriority: fetchpriority,
        data: event_image_data(event.image, data),
        aria: aria
      )
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

  def explore_filter_params_with(overrides = {})
    next_params = request.query_parameters.slice(
      "query",
      "city",
      "category",
      "date_filter",
      "start_date",
      "end_date",
      "time_filter",
      "price_filter",
      "availability_filter",
      "registration_filter",
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

  def prepared_event_attendance_counts
    @event_attendance_counts || {}
  end

  def prepared_event_attendee_previews
    @event_attendee_previews || {}
  end

  def event_image_source(image, variant)
    return rails_storage_redirect_path(image, expires_in: EVENT_IMAGE_PROXY_EXPIRES_IN) unless image.variable?

    rails_representation_proxy_path(
      image.variant(Event::IMAGE_VARIANTS.fetch(variant)).processed,
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
end
