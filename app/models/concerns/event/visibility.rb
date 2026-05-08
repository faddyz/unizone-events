module Event::Visibility
  extend ActiveSupport::Concern

  included do
    scope :upcoming, -> { where("#{Event::PUBLIC_EXPIRY_SQL} >= ?", Time.current).order(date: :asc) }
    scope :published_visible, -> { published.where("#{Event::PUBLIC_EXPIRY_SQL} >= ?", Time.current) }
    scope :not_started, -> { where("date > ?", Time.current) }
  end

  def expired?
    reference = public_expiry_at
    reference.present? && reference < Time.current
  end

  def ongoing?
    return false if date.blank?

    reference = public_expiry_at
    reference.present? && date <= Time.current && reference > Time.current
  end

  def public_expiry_at
    return date if imported? && suspicious_imported_end_date?

    end_date || date
  end

  def suspicious_imported_end_date?
    imported? && end_date.present? && date.present? && end_date > date + Event::MAX_IMPORTED_PUBLIC_DURATION
  end

  def publicly_visible?
    published? && !expired?
  end

  def visible_to_public?
    publicly_visible?
  end
end
