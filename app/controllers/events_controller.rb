class EventsController < ApplicationController
  before_action :set_event, only: :show

  def index
    @events = EventSearch.new(scope: published_scope, params: search_params).results.limit(8)
    @featured_events = published_scope
                       .left_joins(:attendances)
                       .select("events.*, COALESCE(SUM(CASE WHEN attendances.status = 'going' THEN 1 ELSE 0 END), 0) AS going_score")
                       .group("events.id")
                       .order(Arel.sql("going_score DESC"), date: :asc)
                       .limit(6)
    @categories = Event.categories.keys.map { |category| [Event.new(category: category).category_title, category] }
  end

  def explore
    @events = EventSearch.new(scope: published_scope, params: search_params).results.page(params[:page]).per(12)
    @categories = Event.categories.keys.map { |category| [Event.new(category: category).category_title, category] }
  end

  def show
    authorize @event

    @similar_events = @event.similar_events
    @organizer_other_events = @event.organizer_other_events
    @attendance = current_user&.attendances&.find_by(event: @event)
    @attendee_preview = @event.going_users.limit(5)
  end

  private

  def set_event
    @event = policy_scope(Event).friendly.find(params[:id])
  end

  def published_scope
    Event.published.with_attached_image.includes(:user)
  end

  def search_params
    params.permit(:query, :date, :date_filter, :start_date, :end_date, :price_filter, :sort_by, :category, category: [])
  end
end
