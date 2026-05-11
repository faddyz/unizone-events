class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :terms_of_service ])
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
    @event_attendance_status_counts ||= {}
    @event_attendee_previews ||= {}

    grouped_counts = Attendance.where(event_id: ids).group(:event_id, :status).count
    ids.each do |event_id|
      @event_attendance_status_counts[event_id] = default_attendance_status_counts
    end
    grouped_counts.each do |(event_id, status), count|
      @event_attendance_status_counts[event_id][status.to_s] = count
    end

    @event_attendance_counts.merge!(
      @event_attendance_status_counts.slice(*ids).transform_values { |counts| counts.fetch("going", 0).to_i }
    )

    ranked_attendances = Attendance
                         .where(event_id: ids, status: "going")
                         .select("attendances.*, ROW_NUMBER() OVER (PARTITION BY attendances.event_id ORDER BY attendances.created_at ASC) AS preview_rank")

    previews = Hash.new { |hash, key| hash[key] = [] }
    Attendance
      .from(ranked_attendances, :attendances)
      .where("preview_rank <= ?", preview_limit)
      .includes(:user)
      .order(:event_id, :created_at)
      .each do |attendance|
      preview = previews[attendance.event_id]
      preview << attendance.user
    end

    @event_attendee_previews.merge!(previews)
  end

  def event_attendance_status_counts_for(event)
    default_attendance_status_counts.merge(
      (@event_attendance_status_counts || {}).fetch(event.id, {})
    )
  end

  def prepare_event_attendance_statuses(events)
    records = Array(events).compact
    ids = records.map(&:id).compact.uniq
    @event_attendance_statuses = {}
    return if ids.blank? || !user_signed_in?

    @event_attendance_statuses = current_user
                                  .attendances
                                  .where(event_id: ids)
                                  .pluck(:event_id, :status)
                                  .to_h
  end

  def default_attendance_status_counts
    Attendance.statuses.keys.index_with(0)
  end
end
