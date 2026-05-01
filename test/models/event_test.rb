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
