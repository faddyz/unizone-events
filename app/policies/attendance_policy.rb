class AttendancePolicy < ApplicationPolicy
  def create?
    attendable?
  end

  def update?
    attendable?
  end

  def destroy?
    attendable?
  end

  private

  def attendable?
    user.present? && record.published?
  end
end
