class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @owned_events = current_user.events.order(created_at: :desc)
    @rsvps = current_user.attendances.includes(:event).order(updated_at: :desc)
    @upcoming_rsvps = current_user.attendances.includes(:event).joins(:event).where("events.date >= ?", Time.current).order("events.date ASC")
    @review_events = current_user.events.submitted.order(created_at: :desc)
    @live_events_count = current_user.events.published.count
  end
end
