class ExternalEventCandidatePolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def scan?
    user&.admin?
  end

  def bulk?
    user&.admin?
  end

  def approve?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def skip?
    user&.admin?
  end

  def cleanup?
    user&.admin?
  end

  def reset_import_pool?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.none
    end
  end
end
