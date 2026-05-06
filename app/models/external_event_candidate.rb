class ExternalEventCandidate < ApplicationRecord
  SOURCE_ETKINLIK_IO = "etkinlik_io"
  TICKET_URL_KINDS = Event::TICKET_URL_KINDS
  URL_FORMAT = Event::VALID_REMOTE_URL

  belongs_to :resolved_event, class_name: "Event", optional: true

  enum :status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected",
    skipped: "skipped",
    hidden: "hidden",
    expired: "expired"
  }, default: :pending, validate: true

  validates :source, :external_id, :status, presence: true
  validates :external_id, uniqueness: { scope: :source }
  validates :ticket_url_kind, inclusion: { in: TICKET_URL_KINDS, allow_blank: true }
  validates :poster_url, :ticket_url, :external_url, format: { with: URL_FORMAT, allow_blank: true }

  scope :reviewable, -> { pending.order(priority: :desc, starts_at: :asc, created_at: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :expired_by_clock, -> { where("COALESCE(ends_at, starts_at) < ?", Time.current) }

  def self.status_counts
    statuses.keys.index_with { |status| where(status: status).count }
  end

  def expired_by_clock?
    reference = ends_at || starts_at
    reference.present? && reference < Time.current
  end

  def real_ticket_url?
    ticket_url.present? && Event.ticket_kind_linkable?(ticket_url_kind)
  end

  def source_url
    external_url.presence || (ticket_url if ticket_url_kind.in?(%w[etkinlik_detail source detail])).presence
  end
end
