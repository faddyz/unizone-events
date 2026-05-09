class Event < ApplicationRecord
  extend FriendlyId

  VALID_TICKET_URL = /\Ahttps?:\/\/[^\s]+\z/i
  VALID_REMOTE_URL = /\Ahttps?:\/\/[^\s]+\z/i
  TICKET_URL_KINDS = %w[external_ticket ticket redirect_ticket etkinlik_detail unknown].freeze
  MAX_IMPORTED_PUBLIC_DURATION = 18.hours
  PUBLIC_EXPIRY_SQL = <<~SQL.squish.freeze
    CASE
      WHEN end_date IS NOT NULL
        AND (external_source IS NULL OR end_date <= date + INTERVAL '18 hours')
      THEN end_date
      ELSE date
    END
  SQL
  MAX_IMAGE_SIZE = 5.megabytes
  ACCEPTABLE_IMAGE_TYPES = [ "image/jpeg", "image/jpg", "image/png", "image/webp" ].freeze
  IMAGE_VARIANT_DIMENSIONS = {
    card: [ 960, 540 ],
    list: [ 640, 360 ],
    thumb: [ 360, 220 ],
    detail: [ 1200, 1500 ],
    lightbox: [ 1800, 2200 ]
  }.freeze
  IMAGE_VARIANT_SAVER_OPTIONS = { strip: true }.freeze
  IMAGE_VARIANTS = {
    card: { resize_to_limit: IMAGE_VARIANT_DIMENSIONS.fetch(:card), format: :jpg, saver: IMAGE_VARIANT_SAVER_OPTIONS },
    list: { resize_to_limit: IMAGE_VARIANT_DIMENSIONS.fetch(:list), format: :jpg, saver: IMAGE_VARIANT_SAVER_OPTIONS },
    thumb: { resize_to_limit: IMAGE_VARIANT_DIMENSIONS.fetch(:thumb), format: :jpg, saver: IMAGE_VARIANT_SAVER_OPTIONS },
    detail: { resize_to_limit: IMAGE_VARIANT_DIMENSIONS.fetch(:detail), format: :jpg, saver: IMAGE_VARIANT_SAVER_OPTIONS },
    lightbox: { resize_to_limit: IMAGE_VARIANT_DIMENSIONS.fetch(:lightbox), format: :jpg, saver: IMAGE_VARIANT_SAVER_OPTIONS }
  }.freeze

  CITY_OPTIONS = [
    "Adana",
    "Adıyaman",
    "Afyonkarahisar",
    "Ağrı",
    "Aksaray",
    "Amasya",
    "Ankara",
    "Antalya",
    "Ardahan",
    "Artvin",
    "Aydın",
    "Balıkesir",
    "Bartın",
    "Batman",
    "Bayburt",
    "Bilecik",
    "Bingöl",
    "Bitlis",
    "Bolu",
    "Burdur",
    "Bursa",
    "Çanakkale",
    "Çankırı",
    "Çorum",
    "Denizli",
    "Diyarbakır",
    "Düzce",
    "Edirne",
    "Elazığ",
    "Erzincan",
    "Erzurum",
    "Eskişehir",
    "Gaziantep",
    "Giresun",
    "Gümüşhane",
    "Hakkari",
    "Hatay",
    "Iğdır",
    "Isparta",
    "İstanbul",
    "İzmir",
    "Kahramanmaraş",
    "Karabük",
    "Karaman",
    "Kars",
    "Kastamonu",
    "Kayseri",
    "Kırıkkale",
    "Kırklareli",
    "Kırşehir",
    "Kilis",
    "Kocaeli",
    "Konya",
    "Kütahya",
    "Malatya",
    "Manisa",
    "Mardin",
    "Mersin",
    "Muğla",
    "Muş",
    "Nevşehir",
    "Niğde",
    "Ordu",
    "Osmaniye",
    "Rize",
    "Sakarya",
    "Samsun",
    "Siirt",
    "Sinop",
    "Sivas",
    "Şanlıurfa",
    "Şırnak",
    "Tekirdağ",
    "Tokat",
    "Trabzon",
    "Tunceli",
    "Uşak",
    "Van",
    "Yalova",
    "Yozgat",
    "Zonguldak",
    "Online"
  ].freeze

  include Event::Ticketing
  include Event::Images
  include Event::Visibility
  include Event::AttendanceSummary
  include Event::RelatedEvents
  include Event::Lifecycle

  friendly_id :title, use: :slugged

  belongs_to :user

  enum :status, {
    draft: "draft",
    submitted: "submitted",
    published: "published",
    rejected: "rejected",
    cancelled: "cancelled"
  }, default: :draft, validate: true

  enum :category, {
    music: "music",
    festival: "festival",
    art_exhibition: "art_exhibition",
    culture: "culture",
    conference: "conference",
    workshop: "workshop",
    networking: "networking",
    technology: "technology",
    education: "education",
    business: "business",
    career: "career",
    food_lifestyle: "food_lifestyle",
    nightlife: "nightlife",
    sports_wellness: "sports_wellness",
    theater: "theater",
    family: "family",
    community: "community"
  }, default: :community

  CATEGORY_TITLES = {
    music: "Music",
    festival: "Festival",
    art_exhibition: "Art & Exhibitions",
    culture: "Culture",
    conference: "Conference",
    workshop: "Workshop",
    networking: "Meetups",
    technology: "Tech",
    education: "Learning",
    business: "Business",
    career: "Career",
    food_lifestyle: "Food & Lifestyle",
    nightlife: "Nightlife",
    sports_wellness: "Sports & Wellness",
    theater: "Stage",
    family: "Family",
    community: "Community"
  }.freeze

  attribute :city, :string, default: "İstanbul"

  validates :title, :description, :date, :location, :city, :category, presence: true
  validates :city, inclusion: { in: CITY_OPTIONS }
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :capacity, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :editor_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :ticket_url, format: { with: VALID_TICKET_URL, allow_blank: true }
  validates :external_url, :remote_poster_url, format: { with: VALID_REMOTE_URL, allow_blank: true }
  validates :ticket_url_kind, inclusion: { in: TICKET_URL_KINDS, allow_blank: true }

  scope :by_query, ->(query) do
    query = query.to_s.downcase.strip
    where(
      "LOWER(title) LIKE :query OR LOWER(description) LIKE :query OR LOWER(location) LIKE :query OR LOWER(city) LIKE :query",
      query: "%#{query}%"
    )
  end

  scope :by_date, ->(date) { where("date >= ?", date) if date.present? }
  scope :by_category, ->(categories) { where(category: categories) if categories.present? }
  scope :by_city, ->(city) { where(city: city) if city.present? }

  def category_title
    I18n.t("categories.#{category}", default: CATEGORY_TITLES.fetch(category.to_sym, category.to_s.humanize))
  rescue StandardError
    "Bilinmeyen"
  end

  def normalize_friendly_id(string)
    string.to_s.parameterize(preserve_case: false, separator: "-")
  end

  def should_generate_new_friendly_id?
    will_save_change_to_title? || super
  end

end
