class Admin::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :publish, :reject, :cancel ]
  before_action :authorize_index!

  def index
    @filter = params[:filter].presence || "submitted"
    @events = filtered_events.page(params[:page]).per(12)
    @stats = {
      submitted: Event.submitted.count,
      published: Event.published.count,
      rejected: Event.rejected.count,
      cancelled: Event.cancelled.count
    }
  end

  def show
    authorize @event, :publish?
  end

  def edit
    authorize @event, :publish?
  end

  def update
    authorize @event, :publish?

    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: t("flash.event_details_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    authorize @event, :publish?
    @event.publish!
    redirect_to admin_event_path(@event), notice: t("flash.event_live")
  end

  def reject
    authorize @event, :reject?
    @event.reject!(note: params[:review_note].presence)
    redirect_to admin_event_path(@event), notice: t("flash.event_sent_back")
  end

  def cancel
    authorize @event, :cancel?
    @event.cancel!
    redirect_to admin_event_path(@event), notice: t("flash.event_cancelled")
  end

  def destroy
    authorize @event, :publish?
    @event.destroy
    redirect_to admin_events_path, notice: t("flash.event_deleted")
  end

  private

  def authorize_index!
    authorize Event, :publish?
  end

  def set_event
    @event = Event.friendly.find(params[:id])
  end

  def filtered_events
    scope = policy_scope(Event).with_attached_image.includes(:user).order(created_at: :desc)
    return scope if @filter == "all"

    Event.statuses.key?(@filter) ? scope.where(status: @filter) : scope
  end

  def event_params
    params.require(:event).permit(:title, :description, :date, :location, :city, :category, :price, :ticket_url, :capacity, :image, :status, :review_note)
  end
end
