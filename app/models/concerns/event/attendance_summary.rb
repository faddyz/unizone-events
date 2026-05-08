module Event::AttendanceSummary
  extend ActiveSupport::Concern

  included do
    has_many :attendances, dependent: :destroy
    has_many :attendees, -> { where(attendances: { status: "going" }) },
             through: :attendances,
             source: :user
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

  private

  def attendance_count_for(status)
    if association(:attendances).loaded?
      attendances.count { |attendance| attendance.status == status.to_s }
    else
      attendances.where(status: status).count
    end
  end
end
