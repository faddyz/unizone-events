require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
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
