class Organizer::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :submit ]

  def index
    @status_tabs = [
      [ "all", "Tümü" ],
      [ "draft", event_status_label_for("draft") ],
      [ "submitted", event_status_label_for("submitted") ],
      [ "published", event_status_label_for("published") ],
      [ "rejected", event_status_label_for("rejected") ]
    ]
    @selected_status = @status_tabs.map(&:first).include?(params[:status].to_s) ? params[:status].to_s : "all"
    @query = params[:query].to_s.strip

    events_scope = current_user.events.with_attached_image.includes(:attendances).order(created_at: :desc)
    events_scope = events_scope.public_send(@selected_status) unless @selected_status == "all"
    if @query.present?
      events_scope = events_scope.where(
        "LOWER(title) LIKE :query OR LOWER(location) LIKE :query OR LOWER(city) LIKE :query",
        query: "%#{@query.downcase}%"
      )
    end

    @events = events_scope
    @stats = {
      total: current_user.events.count,
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
    @event = current_user.events.build(event_params.merge(status: "submitted"))
    authorize @event

    if @event.save
      redirect_to organizer_event_path(@event), notice: t("flash.event_submitted")
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
    params.require(:event).permit(:title, :description, :date, :location, :city, :category, :price, :ticket_url, :capacity, :image)
  end

  def event_status_label_for(status)
    I18n.t("statuses.#{status}", default: status.to_s.humanize)
  end
end
