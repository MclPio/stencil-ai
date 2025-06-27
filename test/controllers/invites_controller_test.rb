require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @non_admin = users(:free_user)
  end

  # --- Authorization Tests ---

  test "non-admin cannot access invite pages and is redirected" do
    sign_in_as @non_admin

    get invites_url
    assert_redirected_to root_path
  end

  test "admin can access invite pages" do
    sign_in_as @admin

    get new_invite_url
    assert_response :success
  end

  # --- Create Action Tests ---

  test "admin can create a standard single-use invite" do
    sign_in_as @admin
    assert_difference "Invite.count", 1 do
      post invites_url, params: { invite: { expires_at: 1.day.from_now, reusable: "0" } }
    end

    new_invite = Invite.last
    assert_redirected_to invites_url
    assert_not new_invite.reusable?, "The created invite should not be reusable"
  end

  test "admin can create a reusable invite" do
    sign_in_as @admin
    assert_difference "Invite.count", 1 do
      post invites_url, params: { invite: { expires_at: 1.day.from_now, reusable: "1" } }
    end

    new_invite = Invite.last
    assert_redirected_to invites_url
    assert new_invite.reusable?, "The created invite should be reusable"
  end

  # --- Destroy Action Tests ---

  test "admin can destroy an unused invite" do
    sign_in_as @admin
    invite_to_delete = @admin.invites.create! # Create a fresh invite to delete

    assert_difference "Invite.count", -1 do
      delete invite_url(invite_to_delete)
    end

    assert_redirected_to invites_url
    assert_equal "Invite code was successfully deleted.", flash[:notice]
  end
end

def sign_in_as(user)
  post session_url, params: { email_address: user.email_address, password: "password" }
end
