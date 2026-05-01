class Event < ApplicationRecord
  extend FriendlyId

  VALID_TICKET_URL = /\Ahttps?:\/\/[^\s]+\z/i
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
    "Zonguldak"
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
    general: "general",
    technology: "technology",
    music: "music",
    art: "art",
    sports: "sports",
    education: "education",
    concert: "concert",
    festival: "festival",
    workshop: "workshop",
    party: "party",
    theater: "theater",
    exhibition: "exhibition",
    conference: "conference",
    networking: "networking"
  }, default: :general

  CATEGORY_TITLES = {
    general: "Community",
    technology: "Tech",
    music: "Music",
    art: "Art & Design",
    sports: "Sports",
    education: "Learning",
    concert: "Live Music",
    festival: "Festival",
    workshop: "Workshop",
    party: "Nightlife",
    theater: "Stage",
    exhibition: "Exhibition",
    conference: "Conference",
    networking: "Meetups"
  }.freeze

  attribute :city, :string, default: "İstanbul"

  validates :title, :description, :date, :location, :city, :category, presence: true
  validates :city, inclusion: { in: CITY_OPTIONS }
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :capacity, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :ticket_url, format: { with: VALID_TICKET_URL, allow_blank: true }
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
  scope :upcoming, -> { where("date >= ?", Time.current).order(date: :asc) }
  scope :published_visible, -> { published.where("date >= ?", 1.day.ago) }

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
    Event.published
         .with_attached_image
         .includes(:user)
         .where(category: category)
         .where.not(id: id)
         .where("date >= ?", Time.current)
         .order(date: :asc)
         .limit(limit)
  end

  def organizer_other_events(limit = 4)
    user.events
        .published
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
    price.nil? || price.to_f.zero?
  end

  def visible_to_public?
    published?
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
    image.attached? ? image : "https://placehold.co/600x350/e2e8f0/0f172a?text=#{title.truncate(20)}"
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
