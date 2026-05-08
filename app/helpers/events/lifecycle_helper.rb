module Events
  module LifecycleHelper
    def event_lifecycle_hint(event)
      case event.status
      when "draft"
        I18n.t("lifecycle.draft")
      when "submitted"
        I18n.t("lifecycle.submitted")
      when "published"
        I18n.t("lifecycle.published")
      when "rejected"
        event.review_note.presence || I18n.t("lifecycle.rejected")
      when "cancelled"
        I18n.t("lifecycle.cancelled")
      else
        I18n.t("lifecycle.unknown")
      end
    end

    def event_lifecycle_step(event)
      Event.statuses.keys.index(event.status).to_i + 1
    end

    def event_lifecycle_statuses(event)
      statuses = %w[draft submitted]
      statuses << event.status if event.rejected? || event.cancelled?
      statuses << "published"
      statuses
    end

    def event_lifecycle_completed?(event, status)
      case event.status
      when "draft"
        status == "draft"
      when "submitted"
        %w[draft submitted].include?(status)
      when "published"
        %w[draft submitted published].include?(status)
      when "rejected", "cancelled"
        %w[draft submitted].include?(status) || status == event.status
      else
        status == event.status
      end
    end

  end
end
