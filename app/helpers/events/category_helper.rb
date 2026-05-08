module Events
  module CategoryHelper
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

    def attendance_status_badge_classes(status)
      "inline-flex items-center rounded-full px-3 py-1 text-xs font-bold #{RSVP_BADGE_COLORS.fetch(status.to_s, RSVP_BADGE_COLORS["going"])}"
    end

    def attendance_status_label(status)
      I18n.t("rsvps.#{status}", default: status.to_s.humanize)
    end

  private

    def event_category_key(event_or_category)
      event_or_category.respond_to?(:category) ? event_or_category.category.to_s : event_or_category.to_s
    end

  end
end
