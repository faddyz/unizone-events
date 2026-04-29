class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, {
    going: "going",
    interested: "interested",
    not_going: "not_going"
  }, default: :going, validate: true

  validates :user_id, presence: true
  validates :event_id, presence: true
  validates :user_id, uniqueness: { scope: :event_id, message: "has already RSVP'd to this event" }

  scope :for_event, ->(event_id) { where(event_id: event_id) }
  scope :going_for_event, ->(event_id) { for_event(event_id).where(status: "going") }
  scope :interested_for_event, ->(event_id) { for_event(event_id).where(status: "interested") }
  scope :not_going_for_event, ->(event_id) { for_event(event_id).where(status: "not_going") }
end
