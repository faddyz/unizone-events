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
end
