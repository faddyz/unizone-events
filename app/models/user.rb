class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, dependent: :destroy
  has_many :attendances, dependent: :destroy

  has_many :attending_events, -> { where(attendances: { status: 'attending' }) },
           through: :attendances,
           source: :event

  def attending?(event)
    attendances.exists?(event: event, status: 'attending')
  end

  def maybe_attending?(event)
    attendances.exists?(event: event, status: 'maybe')
  end

  def declined?(event)
    attendances.exists?(event: event, status: 'declined')
  end

  def attendance_status(event)
    attendance = attendances.find_by(event: event)
    attendance ? attendance.status : nil
  end

  def admin?
    admin
  end
end
