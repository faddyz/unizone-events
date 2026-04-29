class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, dependent: :destroy
  has_many :attendances, dependent: :destroy

  has_many :going_events, -> { where(attendances: { status: "going" }) },
           through: :attendances,
           source: :event

  has_many :interested_events, -> { where(attendances: { status: "interested" }) },
           through: :attendances,
           source: :event

  def organizer?
    events.exists?
  end

  def going?(event)
    attendances.exists?(event: event, status: "going")
  end

  def interested?(event)
    attendances.exists?(event: event, status: "interested")
  end

  def not_going?(event)
    attendances.exists?(event: event, status: "not_going")
  end

  def attendance_status(event)
    attendances.find_by(event: event)&.status
  end

  def admin?
    admin
  end
end
