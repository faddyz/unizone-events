class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_attendance, only: [:destroy]
  
  # POST /events/:event_id/attendances
  def create
    # Kullanıcının mevcut katılım durumunu bul veya yeni oluştur
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
  
  # DELETE /events/:event_id/attendances
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
    # AJAX uygulamasında status JSON gövdesinden gelebilir
    params.permit(:status)
  end
end 