class Organizer::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy, :submit]

  def index
    @events = current_user.events.order(created_at: :desc)
    @stats = {
      draft: current_user.events.draft.count,
      submitted: current_user.events.submitted.count,
      published: current_user.events.published.count,
      rejected: current_user.events.rejected.count
    }
  end

  def show
    authorize @event
  end

  def new
    @event = current_user.events.build
    authorize @event
  end

  def create
    @event = current_user.events.build(event_params.merge(status: "draft"))
    authorize @event

    if @event.save
      redirect_to organizer_event_path(@event), notice: t("flash.draft_saved")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @event
  end

  def update
    authorize @event

    if @event.update(event_params)
      @event.submit_for_review! if @event.published?
      redirect_to organizer_event_path(@event), notice: t("flash.event_saved")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def submit
    authorize @event, :submit?
    @event.submit_for_review!
    redirect_to organizer_event_path(@event), notice: t("flash.event_submitted")
  end

  def destroy
    authorize @event
    @event.destroy
    redirect_to organizer_events_path, notice: t("flash.event_deleted")
  end

  private

  def set_event
    @event = current_user.events.friendly.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :date, :location, :category, :price, :image)
  end
end
