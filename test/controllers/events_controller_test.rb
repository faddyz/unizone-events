require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_event = events(:published_event)
    @submitted_event = events(:submitted_event)
    @owner_draft_event = events(:owner_draft_event)
    @member = users(:one)
    @admin = users(:two)
    @other_user = users(:three)
  end

  test "public pages only surface published events" do
    get root_path
    assert_response :success
    assert_includes response.body, @published_event.title

    get explore_events_path
    assert_response :success
    assert_includes response.body, @published_event.title
    refute_includes response.body, @submitted_event.title
    refute_includes response.body, @owner_draft_event.title
  end

  test "guest cannot view non public event" do
    get event_path(@owner_draft_event)

    assert_response :not_found
  end

  test "owner can view organizer event page" do
    sign_in @member

    get organizer_event_path(@owner_draft_event)

    assert_response :success
  end

  test "organizer can submit draft for review" do
    sign_in @member

    patch submit_organizer_event_path(@owner_draft_event)

    assert_redirected_to organizer_event_path(@owner_draft_event.reload)
    assert_equal "submitted", @owner_draft_event.reload.status
  end

  test "admin can publish submitted event" do
    sign_in @admin

    patch publish_admin_event_path(@submitted_event)

    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "published", @submitted_event.reload.status
  end

  test "non admin cannot access admin moderation" do
    sign_in @member

    get admin_events_path

    assert_redirected_to root_path
  end

  test "non owner cannot access another organizer event" do
    sign_in @other_user

    get organizer_event_path(@owner_draft_event)

    assert_response :not_found
  end
end
