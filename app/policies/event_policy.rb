class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owner? || user&.admin?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner? || user&.admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner? || user&.admin?
  end

  def submit?
    owner? || user&.admin?
  end

  def publish?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def cancel?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      return scope.published.or(scope.where(user: user)) if user.present?

      scope.published
    end
  end

  private

  def owner?
    user.present? && record.user == user
  end
end
