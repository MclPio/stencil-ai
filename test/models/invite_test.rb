require "test_helper"

class InviteTest < ActiveSupport::TestCase
  # --- Tests for active? method ---

  test "a new single-use invite is active" do
    invite = Invite.new(admin: users(:admin_user))
    assert invite.active?, "A new, unexpired, single-use invite should be active"
  end

  test "a new reusable invite is active" do
    invite = Invite.new(admin: users(:admin_user), reusable: true)
    assert invite.active?, "A new, unexpired, reusable invite should be active"
  end

  test "a used single-use invite is not active" do
    invite = invites(:paid_user_invite) # This fixture has a used_by_id
    assert_not invite.active?, "A used single-use invite should not be active"
  end

  test "a reusable invite is still active even if it has been conceptually 'used'" do
    # In our system, reusable invites never get a `used_by_id`, so we test its state.
    reusable_invite = invites(:reusable_invite)
    assert reusable_invite.active?, "A reusable invite should remain active"
  end

  test "an expired single-use invite is not active" do
    invite = invites(:unused_invite)
    invite.update_column(:expires_at, 1.day.ago)
    assert_not invite.active?, "An expired single-use invite should not be active"
  end

  test "an expired reusable invite is not active" do
    invite = invites(:reusable_invite)
    invite.update_column(:expires_at, 1.day.ago)
    assert_not invite.active?, "An expired reusable invite should not be active"
  end

  # --- Tests for validations and defaults ---

  test "a new invite defaults to not reusable" do
    invite = Invite.new(admin: users(:admin_user))
    assert_not invite.reusable?, "A new invite should default to reusable: false"
  end

  test "cannot destroy an invite that has been used" do
    invite = invites(:paid_user_invite)
    assert_not invite.destroy, "Should not be able to destroy a used invite"
    assert_includes invite.errors[:base], "Cannot delete invite code that has been used by a registered user"
  end

  test "can destroy an unused invite" do
    invite = invites(:unused_invite)
    assert invite.destroy, "Should be able to destroy an unused invite"
  end
end
