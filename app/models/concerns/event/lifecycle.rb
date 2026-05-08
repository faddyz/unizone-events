module Event::Lifecycle
  extend ActiveSupport::Concern

  included do
    before_save :sync_status_metadata
  end

  def reviewable?
    submitted?
  end

  def submit_for_review!
    update!(status: "submitted", approved: false, review_note: nil)
  end

  def publish!
    update!(status: "published", approved: true, published_at: published_at || Time.current, review_note: nil)
  end

  def reject!(note: nil)
    update!(status: "rejected", approved: false, review_note: note)
  end

  def cancel!
    update!(status: "cancelled", approved: false, review_note: nil)
  end

  private

  def sync_status_metadata
    if published?
      self.approved = true
      self.published_at ||= Time.current
      self.review_note = nil
    else
      self.approved = false
    end
  end
end
