class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def update?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?

      scope.none
    end
  end

  private

  def admin?
    user&.admin?
  end
end
