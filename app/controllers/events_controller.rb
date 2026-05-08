class EventsController < ApplicationController
  HOME_UPCOMING_EVENTS_LIMIT = 12
  HOME_FEATURED_EVENTS_LIMIT = 12

  before_action :set_event, only: :show

  def index
    @events = EventSearch.new(scope: home_scope, params: search_params)
                         .results
                         .reorder(Arel.sql(home_order_sql))
                         .limit(HOME_UPCOMING_EVENTS_LIMIT)
                         .to_a
    @featured_events = EventRanker.rank(home_scope).limit(HOME_FEATURED_EVENTS_LIMIT).to_a
    @categories = EventFilterState.category_options
    prepare_event_card_data(@events + @featured_events)
  end

  def explore
    filter_state = EventFilterState.new(params)
    @view_mode = filter_state.view_mode
    @events = EventSearch.new(scope: published_scope, params: search_params).results.page(params[:page]).per(12)
    @categories = filter_state.category_options
    @active_filters = filter_state.active_filters
    prepare_event_card_data(@events.to_a)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    authorize @event

    @preview_mode = !@event.published?
    @similar_events = @event.similar_events.to_a
    @organizer_other_events = @event.imported? ? [] : @event.organizer_other_events.to_a
    @attendance = current_user&.attendances&.find_by(event: @event)
    prepare_event_card_data([ @event ] + @similar_events + @organizer_other_events, preview_limit: 5)
    @attendee_preview = @event_attendee_previews.fetch(@event.id, [])
  end

  private

  def set_event
    @event = policy_scope(Event).with_attached_image.includes(:user).friendly.find(params[:id])
  end

  def published_scope
    Event.published_visible.with_attached_image.includes(:user)
  end

  def home_scope
    published_scope.not_started
  end

  def home_order_sql
    [
      EventCityPriority.order_sql,
      "events.date ASC",
      "events.published_at DESC",
      "events.id DESC"
    ].join(", ")
  end

  def search_params
    EventSearchParams.from(params)
  end
end
