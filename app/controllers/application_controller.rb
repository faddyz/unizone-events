class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  private

  def user_not_authorized
    respond_to do |format|
      format.json do
        render json: {
          status: "error",
          message: t("ui.unauthorized")
        }, status: :forbidden
      end

      format.any do
        redirect_to(request.referer || root_path, alert: t("ui.unauthorized"))
      end
    end
  end

  def after_sign_in_path_for(_resource)
    dashboard_path
  end
end
