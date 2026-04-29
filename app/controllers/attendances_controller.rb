class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :authorize_attendance!
  before_action :set_attendance, only: [ :update, :destroy ]

  def create
    attendance = current_user.attendances.find_or_initialize_by(event: @event)
    attendance.status = attendance_params[:status]

    if attendance.save
      render_success
    else
      render_failure(attendance)
    end
  end

  def update
    if @attendance.update(attendance_params)
      render_success
    else
      render_failure(@attendance)
    end
  end

  def destroy
    if @attendance&.destroy
      render json: {
        status: "success",
        message: I18n.t("flash.rsvp_removed"),
        **attendance_counts
      }
    else
      render json: {
        status: "error",
        message: I18n.t("flash.rsvp_error")
      }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def authorize_attendance!
    authorize @event, policy_class: AttendancePolicy
  end

  def set_attendance
    @attendance = current_user.attendances.find_by!(event: @event)
  end

  def attendance_params
    params.require(:attendance).permit(:status)
  rescue ActionController::ParameterMissing
    params.permit(:status)
  end

  def render_success
    render json: {
      status: "success",
      message: I18n.t("flash.rsvp_updated"),
      **attendance_counts
    }
  end

  def attendance_counts
    event = @event.reload

    {
      attendees_count: event.attendees_count,
      interested_attendees_count: event.interested_attendees_count,
      not_going_attendees_count: event.not_going_attendees_count,
      total_responses_count: event.total_responses_count
    }
  end

  def render_failure(attendance)
    render json: {
      status: "error",
      message: attendance.errors.full_messages.to_sentence
    }, status: :unprocessable_entity
  end
end
