module ApplicationHelper
  def page_stylesheet_tags(*names)
    stylesheet_names = names.flatten.compact_blank.uniq

    safe_join(stylesheet_names.map { |name| stylesheet_link_tag(name, "data-turbo-track": "reload") }, "\n")
  end

  def auth_featured_events(limit: 3)
    Event.published_visible
         .with_attached_image
         .left_joins(:attendances)
         .select("events.*, COALESCE(SUM(CASE WHEN attendances.status = 'going' THEN 1 ELSE 0 END), 0) AS going_score")
         .group("events.id")
         .order(Arel.sql("going_score DESC"), date: :asc)
         .limit(limit)
  end
end
