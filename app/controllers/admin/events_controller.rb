class Admin::EventsController < ApplicationController
  ADMIN_FILTERS = [
    [ "submitted", "İnceleme" ],
    [ "published", "Yayında" ],
    [ "rejected", "Düzenleme gerekli" ],
    [ "cancelled", "İptal" ],
    [ "draft", "Taslak" ],
    [ "all", "Tümü" ]
  ].freeze

  before_action :authenticate_user!
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :publish, :reject, :cancel ]
  before_action :authorize_index!

  def index
    @filter_tabs = ADMIN_FILTERS
    @filter = ADMIN_FILTERS.map(&:first).include?(params[:filter].to_s) ? params[:filter].to_s : "submitted"
    @query = params[:query].to_s.strip
    @category = Event.categories.key?(params[:category].to_s) ? params[:category].to_s : nil
    @city = Event::CITY_OPTIONS.include?(params[:city].to_s) ? params[:city].to_s : nil
    @events = filtered_events.page(params[:page]).per(12)
    @next_review = policy_scope(Event).submitted.includes(:user).order(created_at: :asc).first
    @active_filters = @query.present? || @category.present? || @city.present? || @filter != "submitted"
    @stats = {
      total: Event.count,
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
    scope = policy_scope(Event).with_attached_image.includes(:user, :attendances)
    scope = scope.where(status: @filter) unless @filter == "all"
    scope = scope.where(category: @category) if @category.present?
    scope = scope.where(city: @city) if @city.present?
    if @query.present?
      scope = scope.joins(:user).where(
        "LOWER(events.title) LIKE :query OR LOWER(events.description) LIKE :query OR LOWER(events.location) LIKE :query OR LOWER(events.city) LIKE :query OR LOWER(users.email) LIKE :query OR LOWER(users.name) LIKE :query",
        query: "%#{@query.downcase}%"
      )
    end

    @filter == "submitted" ? scope.order(created_at: :asc) : scope.order(created_at: :desc)
  end

  def event_params
    params.require(:event).permit(:title, :description, :date, :location, :city, :category, :price, :ticket_url, :capacity, :image, :status, :review_note)
  end
end
