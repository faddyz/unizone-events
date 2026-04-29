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
end
