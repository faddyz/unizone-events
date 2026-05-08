module Event::RelatedEvents
  def similar_events(limit = 6)
    Event.published_visible
         .with_attached_image
         .includes(:user)
         .where(category: category)
         .where.not(id: id)
         .order(date: :asc)
         .limit(limit)
  end

  def organizer_other_events(limit = 4)
    user.events
        .published_visible
        .with_attached_image
        .includes(:user)
        .where.not(id: id)
        .order(date: :asc)
        .limit(limit)
  end
end
