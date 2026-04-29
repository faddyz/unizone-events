module ApplicationHelper
  def auth_featured_events(limit: 3)
    Event.published_visible
         .left_joins(:attendances)
         .select("events.*, COALESCE(SUM(CASE WHEN attendances.status = 'going' THEN 1 ELSE 0 END), 0) AS going_score")
         .group("events.id")
         .order(Arel.sql("going_score DESC"), date: :asc)
         .limit(limit)
  end
end
