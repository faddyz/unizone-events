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

  def prepare_event_card_data(events, preview_limit: 3)
    records = Array(events).compact
    ids = records.map(&:id).compact.uniq
    return if ids.blank?

    @event_attendance_counts ||= {}
    @event_attendee_previews ||= {}

    @event_attendance_counts.merge!(
      Attendance.where(event_id: ids, status: "going").group(:event_id).count
    )

    previews = Hash.new { |hash, key| hash[key] = [] }
    Attendance.where(event_id: ids, status: "going").includes(:user).order(:created_at).each do |attendance|
      preview = previews[attendance.event_id]
      preview << attendance.user if preview.length < preview_limit
    end

    @event_attendee_previews.merge!(previews)
  end
end
