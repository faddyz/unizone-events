class DashboardsController < ApplicationController
  PLAN_FILTERS = {
    "all" => "Tümü",
    "week" => "Bu Hafta",
    "going" => "Gidiyorum",
    "interested" => "İlgileniyorum"
  }.freeze
  PLAN_PAGE_SIZE = 6
  PLAN_MAX_LIMIT = 48

  before_action :authenticate_user!

  def show
    @plan_filter = params[:filter].presence_in(PLAN_FILTERS.keys) || "all"
    @plan_display_limit = requested_plan_limit

    base_scope = upcoming_plan_scope
    filtered_scope = filtered_plan_scope(base_scope)
    @plan_filter_counts = plan_filter_counts(base_scope)
    @filtered_plan_count = filtered_scope.count
    @filtered_rsvps = filtered_scope.limit(@plan_display_limit).to_a
    @next_plan_display_limit = [ @plan_display_limit + PLAN_PAGE_SIZE, @filtered_plan_count ].min
    @going_rsvps = base_scope.where(status: "going").limit(8).to_a
    @saved_rsvps = base_scope.where(status: "interested").limit(5).to_a
    @next_plan = @going_rsvps.first || base_scope.first
    @calendar_rsvps = calendar_plan_scope(base_scope).to_a

    prepare_event_card_data(dashboard_events)
  end

  private

  def upcoming_plan_scope
    current_user
      .attendances
      .includes(event: { image_attachment: :blob })
      .joins(:event)
      .where(status: %w[going interested])
      .where("events.date >= ?", Time.current)
      .order("events.date ASC")
  end

  def filtered_plan_scope(scope)
    case @plan_filter
    when "week"
      this_week_plan_scope(scope)
    when "going"
      scope.where(status: "going")
    when "interested"
      scope.where(status: "interested")
    else
      scope
    end
  end

  def this_week_plan_scope(scope)
    scope.where(events: { date: Time.current..Time.current.end_of_week })
  end

  def calendar_plan_scope(scope)
    month_start = Date.current.beginning_of_month.beginning_of_week(:monday)
    month_end = Date.current.end_of_month.end_of_week(:monday)

    scope.where(events: { date: month_start.beginning_of_day..month_end.end_of_day })
  end

  def plan_filter_counts(scope)
    {
      "all" => scope.count,
      "week" => this_week_plan_scope(scope).count,
      "going" => scope.where(status: "going").count,
      "interested" => scope.where(status: "interested").count
    }
  end

  def requested_plan_limit
    raw_limit = params[:plans_limit].to_i
    return PLAN_PAGE_SIZE unless raw_limit.positive?

    [ raw_limit, PLAN_MAX_LIMIT ].min
  end

  def dashboard_events
    (
      @filtered_rsvps +
      @going_rsvps +
      @saved_rsvps +
      @calendar_rsvps +
      [ @next_plan ]
    ).compact.map(&:event).uniq
  end
end
