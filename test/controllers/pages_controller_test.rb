require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @popular_event = events(:published_event)
  end

  test "faq page renders successfully" do
    get faq_path

    assert_response :success
    assert_select "h1", "Sık sorulan sorular"
    assert_includes response.body, "Etkinlik keşfi"
    assert_includes response.body, "Biletler ve destek"
  end

  test "privacy policy page renders successfully" do
    get privacy_policy_path

    assert_response :success
    assert_select "h1", "Gizlilik Politikası"
    assert_includes response.body, "formal hukuki görüş"
    assert_includes response.body, "support@unizone.app"
  end

  test "contact page renders successfully" do
    get contact_path

    assert_response :success
    assert_select "h1", "Unizone destek kanalı"
    assert_includes response.body, "support@unizone.app"
    assert_select "a[href^='mailto:support@unizone.app']"
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
