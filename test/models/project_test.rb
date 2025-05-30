require "test_helper"

class ProjectTest < ActiveSupport::TestCase

  # Helper method to create users with a specific account type
  def create_user(account_type)
    # Using SecureRandom to ensure unique email addresses for each user created in tests
    User.create!(
      email_address: "#{account_type}_#{SecureRandom.hex(4)}@example.com",
      password: "password", # Assuming User model handles password hashing
      name: "#{account_type.capitalize} User",
      account_type: account_type
    )
  end

  # --- Tests for Free Users ---
  test "free user can create their first project" do
    free_user = create_user("free")
    project = Project.new(user: free_user, title: "Free User First Project")
    assert project.save, "Free user should be able to save their first project. Errors: #{project.errors.full_messages.join(", ")}"
  end

  test "free user cannot create a second project" do
    free_user = create_user("free")
    # Create the first project successfully
    first_project = Project.create(user: free_user, title: "Free User First Project")
    assert first_project.persisted?, "First project for free user should be created. Errors: #{first_project.errors.full_messages.join(", ")}"

    # Attempt to create the second project
    second_project = Project.new(user: free_user, title: "Free User Second Project")
    assert_not second_project.save, "Second project for free user should not save."
    assert_includes second_project.errors[:base], "Free users are limited to 1 project."
  end

  # --- Tests for Paid Users ---
  test "paid user can create their 10th project" do
    paid_user = create_user("paid")
    9.times do |i|
      project = Project.create(user: paid_user, title: "Paid Project #{i + 1}")
      assert project.persisted?, "Paid user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    tenth_project = Project.new(user: paid_user, title: "Paid Project 10")
    assert tenth_project.save, "Paid user should be able to create their 10th project. Errors: #{tenth_project.errors.full_messages.join(", ")}"
  end

  test "paid user cannot create an 11th project" do
    paid_user = create_user("paid")
    10.times do |i|
      project = Project.create(user: paid_user, title: "Paid Project #{i + 1}")
      assert project.persisted?, "Paid user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    eleventh_project = Project.new(user: paid_user, title: "Paid Project 11")
    assert_not eleventh_project.save, "Eleventh project for paid user should not save."
    assert_includes eleventh_project.errors[:base], "Paid users are limited to 10 projects."
  end

  # --- Tests for Admin Users ---
  test "admin user can create their 10th project" do
    admin_user = create_user("admin")
    9.times do |i|
      project = Project.create(user: admin_user, title: "Admin Project #{i + 1}")
      assert project.persisted?, "Admin user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    tenth_project = Project.new(user: admin_user, title: "Admin Project 10")
    assert tenth_project.save, "Admin user should be able to create their 10th project. Errors: #{tenth_project.errors.full_messages.join(", ")}"
  end

  test "admin user cannot create an 11th project" do
    admin_user = create_user("admin")
    10.times do |i|
      project = Project.create(user: admin_user, title: "Admin Project #{i + 1}")
      assert project.persisted?, "Admin user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    eleventh_project = Project.new(user: admin_user, title: "Admin Project 11")
    assert_not eleventh_project.save, "Eleventh project for admin user should not save."
    assert_includes eleventh_project.errors[:base], "Admin users are limited to 10 projects."
  end
end
