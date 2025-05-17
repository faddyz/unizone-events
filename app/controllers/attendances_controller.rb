class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_attendance, only: [:destroy]
  
  
  def create
    
    attendance = current_user.attendances.find_or_initialize_by(event_id: @event.id)
    attendance.status = attendance_params[:status]
    
    respond_to do |format|
      if attendance.save
        format.json { render json: { 
          status: 'success',
          message: 'Katılım durumunuz güncellendi',
          attendees_count: @event.reload.attendees_count
        } }
      else
        format.json { render json: { 
          status: 'error',
          message: attendance.errors.full_messages.join(', ')
        }, status: :unprocessable_entity }
      end
    end
  end
  
  
  def destroy
    if @attendance&.destroy
      render json: { 
        status: 'success', 
        message: 'Katılım durumunuz silindi.',
        attendees_count: @event.attendees_count
      }
    else
      render json: { 
        status: 'error', 
        message: 'Katılım durumunuz silinirken bir hata oluştu.'
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_event
    @event = Event.friendly.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.json { render json: { 
        status: 'error',
        message: 'Etkinlik bulunamadı'
      }, status: :not_found }
    end
  end
  
  def set_attendance
    @attendance = current_user.attendances.find_by(event: @event)
  end
  
  def attendance_params
    params.require(:attendance).permit(:status)
  rescue ActionController::ParameterMissing
    
    params.permit(:status)
  end
end 