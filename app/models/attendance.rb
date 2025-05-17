class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event
  
  # Katılım durumları
  STATUSES = {
    attending: 'attending',
    maybe: 'maybe',
    declined: 'declined'
  }.freeze
  
  
  def attending?
    status == 'attending'
  end
  
  def maybe?
    status == 'maybe'
  end
  
  def declined?
    status == 'declined'
  end
  
  
  validates :user_id, presence: true
  validates :event_id, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  
  
  validates :user_id, uniqueness: { scope: :event_id, message: "Bu etkinlik için zaten bir katılım durumu belirttiniz." }
  
  
  scope :attending_event, ->(event_id) { where(event_id: event_id, status: 'attending') }
  scope :maybe_event, ->(event_id) { where(event_id: event_id, status: 'maybe') }
  scope :declined_event, ->(event_id) { where(event_id: event_id, status: 'declined') }
end 