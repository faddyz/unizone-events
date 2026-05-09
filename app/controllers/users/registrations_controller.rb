module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def build_resource(hash = nil)
      super
      resource.terms_acceptance_required = true
    end
  end
end
