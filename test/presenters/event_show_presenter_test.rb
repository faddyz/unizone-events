require "test_helper"

class EventShowPresenterTest < ActionView::TestCase
  include EventsHelper

  test "normalizes selected rsvp state" do
    presenter = build_presenter(attendance: Attendance.new(status: "interested"))
    option = { status: "interested", label: "İlgilen!", active_label: "İlgileniyorsun!" }

    assert presenter.interested_selected?
    assert_not presenter.going_selected?
    assert_not presenter.not_going_selected?
    assert_equal "İlgileniyorsun!", presenter.rsvp_label(option)
  end

  test "preview mode disables selected status" do
    presenter = build_presenter(attendance: Attendance.new(status: "going"), preview_mode: true)

    assert_nil presenter.selected_status
    assert_not presenter.going_selected?
  end

  test "exposes external action and poster state through helpers" do
    event = events(:published_event)
    event.ticket_url = "https://tickets.example.test/event"
    event.ticket_url_kind = "external_ticket"
    event.remote_poster_url = "https://cdn.example.test/poster.jpg"
    presenter = build_presenter(event: event)

    assert_equal event_external_action_label(event), presenter.external_action_label
    assert presenter.poster?
    assert_includes presenter.controllers, "poster-lightbox"
    assert_includes presenter.controllers, "external-redirect"
  end

  private

  def build_presenter(event: events(:published_event), attendance: nil, preview_mode: false)
    EventShowPresenter.new(
      event: event,
      current_user: users(:one),
      attendance: attendance,
      attendee_preview: [],
      preview_mode: preview_mode,
      going_count: 2,
      similar_events: [],
      organizer_other_events: [],
      helpers: self
    )
  end
end
