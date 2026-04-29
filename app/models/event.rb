class Event < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :user

  has_one_attached :image

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

  validates :title, :description, :date, :location, :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate :acceptable_image

  scope :by_query, ->(query) do
    query = query.to_s.downcase.strip
    where(
      "LOWER(title) LIKE :query OR LOWER(description) LIKE :query OR LOWER(location) LIKE :query",
      query: "%#{query}%"
    )
  end

  scope :by_date, ->(date) { where("date >= ?", date) if date.present? }
  scope :by_category, ->(categories) { where(category: categories) if categories.present? }
  scope :upcoming, -> { where("date >= ?", Time.current).order(date: :asc) }
  scope :published_visible, -> { published.where("date >= ?", 1.day.ago) }

  def attendees_count
    attendances.where(status: "going").count
  end

  def interested_attendees_count
    attendances.where(status: "interested").count
  end

  def not_going_attendees_count
    attendances.where(status: "not_going").count
  end

  def total_responses_count
    attendances.count
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

  def acceptable_image
    return unless image.attached?

    errors.add(:image, I18n.t("errors.messages.image_too_large")) if image.blob.byte_size > 5.megabytes

    acceptable_types = ["image/jpeg", "image/jpg", "image/png"]
    return if acceptable_types.include?(image.blob.content_type)

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
end
