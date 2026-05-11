class EventShowPresenter
  RSVP_OPTIONS = [
    { status: "going", label: "Katıl!", active_label: "Yerini aldın!", note: "Katılımını netleştir ve etkinlikteki yerini ayır." },
    { status: "interested", label: "İlgilendiğini göster!", active_label: "İlgileniyorsun!", note: "Henüz kesin değilse etkinliği radarında tut." },
    { status: "not_going", label: "Pas geç.", active_label: "Pas geçildi.", note: "Sana uygun değilse seçimini temiz tut." }
  ].freeze

  attr_reader :event, :current_user, :preview_mode, :attendee_preview,
              :attendance, :going_count, :attendance_counts, :similar_events, :organizer_other_events

  def initialize(event:, current_user:, attendance:, attendee_preview:, preview_mode:, going_count:, similar_events:, organizer_other_events:, helpers:, attendance_counts: nil)
    @event = event
    @current_user = current_user
    @attendance = attendance
    @attendee_preview = Array(attendee_preview)
    @preview_mode = preview_mode
    @going_count = going_count.to_i
    @attendance_counts = attendance_counts&.transform_keys(&:to_s)
    @similar_events = Array(similar_events)
    @organizer_other_events = Array(organizer_other_events)
    @helpers = helpers
  end

  def display_title
    @display_title ||= helpers.event_display_title(event)
  end

  def display_description
    @display_description ||= helpers.event_description_text(event, preserve_paragraphs: true)
  end

  def organizer_name
    return if event.imported?

    event.user.name.presence || event.user.email
  end

  def source_name
    "Etkinlik.io" if event.imported?
  end

  def interested_count
    attendance_count("interested") { event.interested_attendees_count }
  end

  def not_going_count
    attendance_count("not_going") { event.not_going_attendees_count }
  end

  def total_responses
    return attendance_counts.values.sum if attendance_counts

    event.total_responses_count
  end

  def capacity
    value = event.capacity.to_i
    value.positive? ? value : nil
  end

  def capacity_percent
    return unless capacity

    [ [ ((going_count.to_f / capacity) * 100).round, 100 ].min, 0 ].max
  end

  def spots_left
    return unless capacity

    [ capacity - going_count, 0 ].max
  end

  def ticket_url
    @ticket_url ||= helpers.event_external_action_url(event)
  end

  def external_action_label
    @external_action_label ||= helpers.event_external_action_label(event)
  end

  def poster?
    @poster = helpers.event_has_poster?(event) if @poster.nil?
    @poster
  end

  def selected_status
    preview_mode ? nil : attendance&.status
  end

  def status_selected?(status)
    selected_status == status.to_s
  end

  def going_selected?
    status_selected?("going")
  end

  def interested_selected?
    status_selected?("interested")
  end

  def not_going_selected?
    status_selected?("not_going")
  end

  def rsvp_label(option)
    status_selected?(option[:status]) ? option[:active_label] : option[:label]
  end

  def share_text
    "#{display_title} etkinliğine göz at."
  end

  def controllers
    @controllers ||= begin
      values = []
      values << "attendance" unless preview_mode
      values << "share" unless preview_mode
      values << "poster-lightbox" if poster?
      values << "external-redirect" if ticket_url && !preview_mode
      values << "event-show-motion"
      values
    end
  end

  def attendance_path
    helpers.event_attendance_path(event)
  end

  def signed_in?
    current_user.present?
  end

  def preview_back_path
    if preview_mode && current_user&.admin?
      helpers.admin_event_path(event)
    elsif preview_mode && current_user == event.user
      helpers.organizer_event_path(event)
    else
      helpers.explore_events_path
    end
  end

  def preview_back_label
    if preview_mode && current_user&.admin?
      "İncelemeye dön"
    elsif preview_mode
      "Etkinliklerime dön"
    else
      "Keşfe dön"
    end
  end

  def public_action_label
    if ticket_url
      helpers.event_external_action_label(event)
    elsif current_user.blank?
      "Giriş yap"
    else
      "Katıl!"
    end
  end

  def title_size_class
    title_length = display_title.length
    if title_length >= 100
      "text-3xl sm:text-4xl lg:text-5xl"
    elsif title_length >= 75
      "text-4xl sm:text-5xl lg:text-6xl"
    else
      "text-5xl sm:text-7xl lg:text-[84px]"
    end
  end

  def title_density_class
    title_length = display_title.length
    if title_length >= 100
      "is-very-long-title"
    elsif title_length >= 75
      "is-long-title"
    else
      ""
    end
  end

  def rsvp_options
    RSVP_OPTIONS
  end

  private

  attr_reader :helpers

  def attendance_count(status)
    return attendance_counts.fetch(status.to_s, 0).to_i if attendance_counts

    yield
  end
end
