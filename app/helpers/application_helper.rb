module ApplicationHelper
  def page_stylesheet_tags(*names)
    stylesheet_names = names.flatten.compact_blank.uniq

    safe_join(stylesheet_names.map { |name| stylesheet_link_tag(name) }, "\n")
  end

  def auth_featured_events(limit: 3)
    EventRanker.rank(Event.published_visible.with_attached_image)
               .limit(limit)
  end
end
