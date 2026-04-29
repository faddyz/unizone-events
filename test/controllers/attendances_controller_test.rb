require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_event = events(:published_event)
    @draft_event = events(:owner_draft_event)
    @user = users(:three)
  end

  test "signed in user can RSVP to published event" do
    sign_in @user

    post event_attendance_path(@published_event), params: { status: "going" }, as: :json

    assert_response :success
    assert_equal "going", @user.attendances.find_by(event: @published_event)&.status
    response_payload = JSON.parse(response.body)
    assert_equal 1, response_payload["attendees_count"]
    assert_equal 0, response_payload["interested_attendees_count"]
  end

  test "signed in user cannot RSVP to draft event" do
    sign_in @user

    post event_attendance_path(@draft_event), params: { status: "going" }, as: :json

    assert_response :forbidden
    assert_nil @user.attendances.find_by(event: @draft_event)
  end
end
