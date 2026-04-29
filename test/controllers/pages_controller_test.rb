require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "signed in user can view account settings" do
    sign_in @user

    get account_profile_path

    assert_response :success
    assert_select "h1", "Profil ve güvenlik"
    assert_select "#profile-settings"
    assert_select "#security-settings"
  end

  test "guest is redirected from account settings" do
    get account_profile_path

    assert_redirected_to new_user_session_path
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

  test "invalid profile update renders account settings with errors" do
    sign_in @user

    patch account_profile_path, params: {
      user: {
        name: "Updated User",
        email: "updated@example.com",
        current_password: ""
      }
    }

    assert_response :unprocessable_entity
    assert_select ".account-form-alert", text: /Profil bilgilerini kontrol et/
    assert_select "#profile-current-password-error"
  end

  test "invalid password update renders account settings with errors" do
    sign_in @user

    patch account_password_path, params: {
      user: {
        current_password: "wrong-password",
        password: "short",
        password_confirmation: "different"
      }
    }

    assert_response :unprocessable_entity
    assert_select ".account-form-alert", text: /Şifre bilgilerini kontrol et/
    assert_select "#security-current-password-error"
  end
end
