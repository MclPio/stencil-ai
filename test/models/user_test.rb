require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "default user account is free" do
    assert true, @user.account_type_free?
  end

  test "can update to other account type" do
    @user.account_type_paid!
    assert true, @user.account_type_paid?
  end
end
