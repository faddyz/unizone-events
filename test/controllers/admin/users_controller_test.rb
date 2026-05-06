require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin-users@example.com", password: "password123", name: "Admin User", admin: true)
    @member = User.create!(email: "member-users@example.com", password: "password123", name: "Member User", admin: false)
    @other_member = User.create!(email: "other-users@example.com", password: "password123", name: "Other User", admin: false)
  end

  test "admin can view user moderation" do
    sign_in @admin, scope: :user

    get admin_users_path, headers: modern_browser_headers

    assert_response :success
    assert_includes response.body, @member.email
    assert_includes response.body, "Admin yap"
  end

  test "non admin cannot view user moderation" do
    sign_in @member, scope: :user

    get admin_users_path, headers: modern_browser_headers

    assert_redirected_to root_path
  end

  test "admin can promote a member" do
    sign_in @admin, scope: :user

    patch admin_user_path(@member), params: { user: { admin: "1" } }, headers: modern_browser_headers

    assert_redirected_to admin_users_path
    assert @member.reload.admin?
  end

  test "admin can remove another admin role" do
    @other_member.update!(admin: true)
    sign_in @admin, scope: :user

    patch admin_user_path(@other_member), params: { user: { admin: "0" } }, headers: modern_browser_headers

    assert_redirected_to admin_users_path
    assert_not @other_member.reload.admin?
  end

  test "admin cannot remove own admin role" do
    sign_in @admin, scope: :user

    patch admin_user_path(@admin), params: { user: { admin: "0" } }, headers: modern_browser_headers

    assert_redirected_to admin_users_path
    assert @admin.reload.admin?
  end

  private

  def modern_browser_headers
    { "User-Agent" => "Mozilla/5.0 AppleWebKit/537.36 Chrome/124.0 Safari/537.36" }
  end
end
