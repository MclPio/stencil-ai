require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  # Load fixtures to make them available in the tests
  fixtures :users, :projects

  # --- Tests for Free Users ---
  test "free user can create their first project" do
    # Get the free user from fixtures
    free_user = users(:free_user)
    # The free user already has one project from the projects.yml fixture
    # So we test if they can save it.
    project = Project.new(user: free_user, title: "Free User First Project")
    assert project.save, "Free user should be able to save their first project. Errors: #{project.errors.full_messages.join(", ")}"
  end

  test "free user cannot create a third project" do
    # Get the free user from fixtures
    free_user = users(:free_user)
    # Create the first project successfully
    first_project = Project.create(user: free_user, title: "Free User First Project")
    assert first_project.persisted?, "First project for free user should be created. Errors: #{first_project.errors.full_messages.join(", ")}"

    # Attempt to create the second project
    second_project = Project.create(user: free_user, title: "Free User Second Project")
    assert second_project.persisted?, "First project for free user should be created. Errors: #{second_project.errors.full_messages.join(", ")}"

    third_project = Project.new(user: free_user, title: "Free User Second Project")
    assert_not third_project.save, "Second project for free user should not save."
    assert_includes third_project.errors[:base], "Free users are limited to 2 project."
  end

  # --- Tests for Paid Users ---
  test "paid user can create their 10th project" do
    # Get the paid user from fixtures
    paid_user = users(:paid_user)
    # Create 9 projects for the paid user
    9.times do |i|
      project = Project.create(user: paid_user, title: "Paid Project #{i + 1}")
      assert project.persisted?, "Paid user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    # Attempt to create the 10th project
    tenth_project = Project.new(user: paid_user, title: "Paid Project 10")
    assert tenth_project.save, "Paid user should be able to create their 10th project. Errors: #{tenth_project.errors.full_messages.join(", ")}"
  end

  test "paid user cannot create an 11th project" do
    # Get the paid user from fixtures
    paid_user = users(:paid_user)
    # Create 10 projects for the paid user
    10.times do |i|
      project = Project.create(user: paid_user, title: "Paid Project #{i + 1}")
      assert project.persisted?, "Paid user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    # Attempt to create the 11th project
    eleventh_project = Project.new(user: paid_user, title: "Paid Project 11")
    assert_not eleventh_project.save, "Eleventh project for paid user should not save."
    assert_includes eleventh_project.errors[:base], "Paid users are limited to 10 projects."
  end

  # --- Tests for Admin Users ---
  test "admin user can create their 10th project" do
    # Get the admin user from fixtures
    admin_user = users(:admin_user)
    # Create 9 projects for the admin user
    9.times do |i|
      project = Project.create(user: admin_user, title: "Admin Project #{i + 1}")
      assert project.persisted?, "Admin user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    # Attempt to create the 10th project
    tenth_project = Project.new(user: admin_user, title: "Admin Project 10")
    assert tenth_project.save, "Admin user should be able to create their 10th project. Errors: #{tenth_project.errors.full_messages.join(", ")}"
  end

  test "admin user cannot create an 11th project" do
    # Get the admin user from fixtures
    admin_user = users(:admin_user)
    # Create 10 projects for the admin user
    10.times do |i|
      project = Project.create(user: admin_user, title: "Admin Project #{i + 1}")
      assert project.persisted?, "Admin user should be able to create project #{i + 1}. Errors: #{project.errors.full_messages.join(", ")}"
    end

    # Attempt to create the 11th project
    eleventh_project = Project.new(user: admin_user, title: "Admin Project 11")
    assert_not eleventh_project.save, "Eleventh project for admin user should not save."
    assert_includes eleventh_project.errors[:base], "Admin users are limited to 10 projects."
  end
end
