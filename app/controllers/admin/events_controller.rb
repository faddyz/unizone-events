class Admin::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_event, only: [:show, :edit, :update, :destroy, :approve]

  def index
    @filter_type = params[:filter_type] || 'all'
    
    @events = case @filter_type
              when 'pending'
                Event.pending.order(created_at: :desc)
              when 'approved'
                Event.approved.order(created_at: :desc)
              else
                Event.all.order(created_at: :desc)
              end
  end

  def pending
    @events = Event.pending.order(created_at: :desc)
    render :index
  end

  def approve
    @event.update(approved: true)
    redirect_to admin_events_path, notice: 'Etkinlik başarıyla onaylandı.'
  end

  def show
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: 'Etkinlik başarıyla güncellendi.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @event.destroy
      redirect_to admin_events_path, notice: 'Etkinlik başarıyla silindi.'
    rescue => e
      Rails.logger.error("Etkinlik silinirken hata oluştu: #{e.message}")
      redirect_to admin_events_path, alert: 'Etkinlik silinirken bir hata oluştu.'
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :date, :location, :category, :price, :approved, :image)
  end

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'Bu sayfaya erişim yetkiniz yok.'
    end
  end
end 