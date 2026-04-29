require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @popular_event = events(:published_event)
  end

  test "auth pages show most attended published events" do
    Attendance.create!(user: users(:three), event: @popular_event, status: "going")

    get new_user_session_path
    assert_response :success
    assert_includes response.body, "En çok katılım alanlar"
    assert_includes response.body, @popular_event.title

    get new_user_registration_path
    assert_response :success
    assert_includes response.body, "En çok katılım alanlar"
    assert_includes response.body, @popular_event.title
  end

  test "signed in user can update profile from account area" do
    sign_in @user

    patch account_profile_path, params: { user: { name: "Updated User", email: @user.email } }

    assert_redirected_to account_profile_path
    assert_equal "Updated User", @user.reload.name
  end

  test "signed in user can update password from account area" do
    sign_in @user

    patch account_password_path, params: {
      user: {
        current_password: "password123",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to account_profile_path
  end
end
