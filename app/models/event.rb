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

  friendly_id :title, use: :slugged

  belongs_to :user

  has_one_attached :image
  attr_accessor :remove_image

  before_validation :normalize_conversion_fields
  before_save :sync_status_metadata

  has_many :attendances, dependent: :destroy
  has_many :attendees, -> { where(attendances: { status: "going" }) },
           through: :attendances,
           source: :user

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
  validate :acceptable_image

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
  scope :upcoming, -> { where("#{PUBLIC_EXPIRY_SQL} >= ?", Time.current).order(date: :asc) }
  scope :published_visible, -> { published.where("#{PUBLIC_EXPIRY_SQL} >= ?", Time.current) }

  def self.classify_ticket_url(ticket_url, _external_url = nil)
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

  def self.ticket_kind_linkable?(kind)
    %w[external_ticket redirect_ticket ticket].include?(kind.to_s)
  end

  def self.etkinlik_host?(host)
    host == "etkinlik.io" || host.end_with?(".etkinlik.io")
  end

  def self.etkinlik_ticket_redirect_path?(path)
    path.start_with?("/redirect-ticket-url") ||
      path.match?(%r{\A/api/v\d+/events/[^/]+/ticket-url\z})
  end

  def attendees_count
    attendance_count_for("going")
  end

  def interested_attendees_count
    attendance_count_for("interested")
  end

  def not_going_attendees_count
    attendance_count_for("not_going")
  end

  def total_responses_count
    if association(:attendances).loaded?
      attendances.size
    else
      attendances.count
    end
  end

  def going_users
    User.joins(:attendances).where(attendances: { event_id: id, status: "going" })
  end

  def similar_events(limit = 6)
    Event.published_visible
         .with_attached_image
         .includes(:user)
         .where(category: category)
         .where.not(id: id)
         .order(date: :asc)
         .limit(limit)
  end

  def organizer_other_events(limit = 4)
    user.events
        .published_visible
        .with_attached_image
        .includes(:user)
        .where.not(id: id)
        .order(date: :asc)
        .limit(limit)
  end

  def category_title
    I18n.t("categories.#{category}", default: CATEGORY_TITLES.fetch(category.to_sym, category.to_s.humanize))
  rescue StandardError
    "Bilinmeyen"
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

  def expired?
    reference = public_expiry_at
    reference.present? && reference < Time.current
  end

  def public_expiry_at
    return date if imported? && suspicious_imported_end_date?

    end_date || date
  end

  def suspicious_imported_end_date?
    imported? && end_date.present? && date.present? && end_date > date + MAX_IMPORTED_PUBLIC_DURATION
  end

  def publicly_visible?
    published? && !expired?
  end

  def visible_to_public?
    publicly_visible?
  end

  def reviewable?
    submitted?
  end

  def submit_for_review!
    update!(status: "submitted", approved: false, review_note: nil)
  end

  def publish!
    update!(status: "published", approved: true, published_at: published_at || Time.current, review_note: nil)
  end

  def reject!(note: nil)
    update!(status: "rejected", approved: false, review_note: note)
  end

  def cancel!
    update!(status: "cancelled", approved: false, review_note: nil)
  end

  def display_image
    return remote_poster_url if remote_poster_url.present?
    return image if image.attached?

    "https://placehold.co/600x350/e2e8f0/0f172a?text=#{title.truncate(20)}"
  end

  def normalize_friendly_id(string)
    string.to_s.parameterize(preserve_case: false, separator: "-")
  end

  def should_generate_new_friendly_id?
    will_save_change_to_title? || super
  end

  private

  def normalize_conversion_fields
    self.ticket_url = ticket_url.to_s.strip.presence
  end

  def acceptable_image
    return unless image.attached?

    if image.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, I18n.t("errors.messages.image_too_large"))
    end

    return if ACCEPTABLE_IMAGE_TYPES.include?(image.blob.content_type.to_s)

    errors.add(:image, I18n.t("errors.messages.image_invalid_type"))
  end

  def sync_status_metadata
    if published?
      self.approved = true
      self.published_at ||= Time.current
      self.review_note = nil
    else
      self.approved = false
    end
  end

  def attendance_count_for(status)
    if association(:attendances).loaded?
      attendances.count { |attendance| attendance.status == status.to_s }
    else
      attendances.where(status: status).count
    end
  end
end
