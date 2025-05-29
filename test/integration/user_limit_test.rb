require "test_helper"

class UserLimitTest < ActionDispatch::IntegrationTest
  setup do
    # Clear existing users to ensure a clean slate
    User.destroy_all
    # Create 99 users to approach the limit
    99.times do |i|
      User.create!(name: "bob{i}", email_address: "user#{i}@example.com", password: "password")
    end
  end

  test "can create user when under limit" do
    user = User.new(name: "joe", email_address: "newuser@example.com", password: "password")
    assert_difference 'User.count', 1 do
      user.save
    end
    assert user.persisted?, "User should be created successfully"
  end

  test "cannot create user when at limit" do
    # Create the 100th user
    User.create!(name: "tim", email_address: "user99@example.com", password: "password")
    # Try to create one more
    user = User.new(name: "peter", email_address: "overlimit@example.com", password: "password")
    assert_no_difference 'User.count' do
      user.save
    end
    assert_not user.persisted?, "User should not be created"
    assert_includes user.errors[:base], "The app only allows 100 users"
  end

  test "can update existing user when at limit" do
    # Create the 100th user
    user = User.create!(name: "andrew", email_address: "user99@example.com", password: "password")
    # Update an existing user
    user.email_address = "updated@example.com"
    assert user.save, "Existing user should be updated successfully"
    assert_equal "updated@example.com", user.reload.email_address
  end
end
