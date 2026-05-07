require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "status defaults to draft" do
    event = Event.new

    assert_equal "draft", event.status
  end

  test "publish sets status and published_at" do
    event = events(:owner_draft_event)

    event.publish!

    assert_equal "published", event.status
    assert_not_nil event.published_at
  end

  test "conversion fields are optional but validated when present" do
    event = events(:published_event)

    event.ticket_url = ""
    event.capacity = nil
    assert event.valid?

    event.ticket_url = "not-a-url"
    event.capacity = 0
    assert_not event.valid?

    event.ticket_url = "https://example.com/register"
    event.capacity = 80
    assert event.valid?
  end

  test "editor score is optional but must stay between zero and one hundred" do
    event = events(:published_event)

    event.editor_score = nil
    assert event.valid?

    event.editor_score = 0
    assert event.valid?

    event.editor_score = 100
    assert event.valid?

    event.editor_score = -1
    assert_not event.valid?

    event.editor_score = 101
    assert_not event.valid?
  end

  test "classifies etkinlik ticket redirects as ticket links" do
    assert_equal "redirect_ticket", Event.classify_ticket_url("https://etkinlik.io/redirect-ticket-url/demo")
    assert_equal "redirect_ticket", Event.classify_ticket_url("https://etkinlik.io/api/v2/events/282895/ticket-url?publisher_code=CBejonrdsX")
    assert Event.ticket_kind_linkable?("redirect_ticket")
  end

  test "published visible excludes events whose end or start time passed" do
    current = Event.create!(
      user: users(:one),
      title: "Current Imported Event",
      description: "Visible because its end date is still in the future.",
      category: "technology",
      date: 2.hours.ago,
      end_date: 2.hours.from_now,
      city: "Online",
      location: "Online",
      status: "published"
    )
    expired = Event.create!(
      user: users(:one),
      title: "Expired Imported Event",
      description: "Hidden because the event time has passed.",
      category: "technology",
      date: 1.minute.ago,
      city: "Online",
      location: "Online",
      status: "published"
    )

    assert_includes Event.published_visible, current
    assert current.ongoing?
    refute_includes Event.published_visible, expired
    refute expired.ongoing?
  end

  test "published visible ignores suspicious long imported end dates" do
    imported = Event.create!(
      user: users(:one),
      title: "Long Imported End Event",
      description: "Hidden because imported end date looks like a series range.",
      category: "music",
      date: 1.day.ago,
      end_date: 20.days.from_now,
      city: "İstanbul",
      location: "Venue",
      status: "published",
      external_source: "etkinlik_io",
      external_id: "long-imported-end-event"
    )
    internal = Event.create!(
      user: users(:one),
      title: "Long Internal Event",
      description: "Visible because internal multi-day events may be intentional.",
      category: "music",
      date: 1.day.ago,
      end_date: 20.days.from_now,
      city: "İstanbul",
      location: "Venue",
      status: "published"
    )

    assert imported.expired?
    refute_includes Event.published_visible, imported
    refute internal.expired?
    assert_includes Event.published_visible, internal
  end

  test "not started excludes ongoing imported events from homepage scope" do
    ongoing = Event.create!(
      user: users(:one),
      title: "Ongoing Imported Event",
      description: "Visible in explore because its end date is still in the future.",
      category: "music",
      date: 30.minutes.ago,
      end_date: 30.minutes.from_now,
      city: "Online",
      location: "Online",
      status: "published",
      external_source: "etkinlik_io",
      external_id: "ongoing-imported-event"
    )

    assert_includes Event.published_visible, ongoing
    assert ongoing.ongoing?
    refute_includes Event.published_visible.not_started, ongoing
  end

  test "image accepts webp and rejects unsupported content types" do
    event = events(:published_event)

    event.image.attach(io: StringIO.new("webp"), filename: "poster.webp", content_type: "image/webp")
    assert event.valid?

    event.image.detach
    event.image.attach(io: StringIO.new("gif"), filename: "poster.gif", content_type: "image/gif")
    assert_not event.valid?
    assert event.errors[:image].present?
  end

  test "image rejects files over size limit" do
    event = events(:published_event)
    oversized = StringIO.new("x" * (Event::MAX_IMAGE_SIZE + 1))

    event.image.attach(io: oversized, filename: "poster.jpg", content_type: "image/jpeg")

    assert_not event.valid?
    assert event.errors[:image].present?
  end
end
