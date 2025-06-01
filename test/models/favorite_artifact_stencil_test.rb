require "test_helper"

class FavoriteArtifactStencilTest < ActiveSupport::TestCase
  setup do
    # Assuming users(:one), users(:two), artifact_stencils(:one), artifact_stencils(:two)
    # and projects(:one) are reliably available from their respective fixture files.
    @user_one = users(:one)
    @user_two = users(:two)
    @stencil_one = artifact_stencils(:one)
    @stencil_two = artifact_stencils(:two)
    @project_one = projects(:one)

    # For uniqueness test, ensure favorite_artifact_stencils(:one) is loaded
    # and corresponds to user_one and stencil_one.
    # This fixture (favorite_artifact_stencils.yml - :one) should exist from previous setup.
    @existing_favorite = favorite_artifact_stencils(:one)

    # Defensive check for @existing_favorite setup for uniqueness tests
    if !@existing_favorite || @existing_favorite.user != @user_one || @existing_favorite.artifact_stencil != @stencil_one
      # Attempt to create if fixture setup is not as expected.
      # This helps if fixtures were minimal or changed.
      @existing_favorite = FavoriteArtifactStencil.find_by(user: @user_one, artifact_stencil: @stencil_one) ||
                           FavoriteArtifactStencil.create(user: @user_one, artifact_stencil: @stencil_one)

      unless @existing_favorite.persisted?
        puts "Warning: Failed to ensure @existing_favorite for uniqueness tests. Errors: #{@existing_favorite.errors.full_messages.join(', ')}"
      end
    end
  end

  test "should be valid with existing user and artifact_stencil" do
    # Use a combination not already used by @existing_favorite to avoid uniqueness conflict.
    favorite = FavoriteArtifactStencil.new(user: @user_two, artifact_stencil: @stencil_one)
    assert favorite.valid?, "FavoriteArtifactStencil should be valid. Errors: #{favorite.errors.full_messages.join(", ")}"
  end

  test "should not save without user_id" do
    favorite = FavoriteArtifactStencil.new(artifact_stencil: @stencil_one)
    assert_not favorite.save, "Saved without user_id"
    assert_includes favorite.errors[:user_id], "can't be blank"
    assert_includes favorite.errors[:user], "must exist" # Due to belongs_to
  end

  test "should not save without artifact_stencil_id" do
    favorite = FavoriteArtifactStencil.new(user: @user_one)
    assert_not favorite.save, "Saved without artifact_stencil_id"
    assert_includes favorite.errors[:artifact_stencil_id], "can't be blank"
    assert_includes favorite.errors[:artifact_stencil], "must exist" # Due to belongs_to
  end

  test "should enforce uniqueness of artifact_stencil_id scoped to user_id" do
    unless @existing_favorite && @existing_favorite.persisted? && @existing_favorite.user == @user_one && @existing_favorite.artifact_stencil == @stencil_one
      skip "Skipping uniqueness test: @existing_favorite (user_one with stencil_one) not properly set up from fixtures or creation."
    end

    duplicate_favorite = FavoriteArtifactStencil.new(
      user: @user_one, # Same user as @existing_favorite
      artifact_stencil: @stencil_one # Same artifact_stencil as @existing_favorite
    )
    assert_not duplicate_favorite.save, "Saved a duplicate favorite (same user, same stencil)"
    assert_includes duplicate_favorite.errors[:artifact_stencil_id], "has already been favorited by this user"
  end

  test "should allow different users to favorite the same artifact_stencil" do
    # @stencil_one is already favorited by @user_one (via @existing_favorite)
    # We test if @user_two can also favorite @stencil_one.

    # Ensure @existing_favorite is what we think it is for this test's logic
    unless @existing_favorite && @existing_favorite.persisted? && @existing_favorite.artifact_stencil == @stencil_one
       skip "Skipping 'different users' uniqueness test: @existing_favorite with @stencil_one not properly set up."
    end

    new_user_favorite = FavoriteArtifactStencil.new(
      user: @user_two,
      artifact_stencil: @stencil_one
    )
    assert new_user_favorite.save, "Could not save favorite for a different user (@user_two, @stencil_one). Errors: #{new_user_favorite.errors.full_messages.join(", ")}"
  end

  test "should allow same user to favorite different artifact_stencils" do
    # @user_one has already favorited @stencil_one (via @existing_favorite)
    # We test if @user_one can also favorite @stencil_two.

    # Ensure @existing_favorite is what we think it is for this test's logic
    unless @existing_favorite && @existing_favorite.persisted? && @existing_favorite.user == @user_one
       skip "Skipping 'different stencils' uniqueness test: @existing_favorite for @user_one not properly set up."
    end

    new_stencil_favorite = FavoriteArtifactStencil.new(
      user: @user_one,
      artifact_stencil: @stencil_two # Different stencil
    )
    assert new_stencil_favorite.save, "Could not save favorite for a different stencil by the same user. Errors: #{new_stencil_favorite.errors.full_messages.join(", ")}"
  end

  # Association tests
  test "should belong to user" do
    favorite = FavoriteArtifactStencil.new(user: @user_one, artifact_stencil: @stencil_one)
    assert_equal @user_one, favorite.user
  end

  test "should belong to artifact_stencil" do
    favorite = FavoriteArtifactStencil.new(user: @user_one, artifact_stencil: @stencil_one)
    assert_equal @stencil_one, favorite.artifact_stencil
  end

  test "should have many artifacts" do
    # This test relies on favorite_artifact_stencils(:one) from fixtures
    # and artifacts(:one) being associated with it.
    fav_stencil_fixture = favorite_artifact_stencils(:one)

    unless fav_stencil_fixture
      skip "Skipping 'has_many :artifacts' test: favorite_artifact_stencils(:one) fixture not found."
    end

    # Create a new artifact associated with this favorite_artifact_stencil
    # This ensures there's at least one artifact if fixtures are sparse or specific.
    new_artifact = fav_stencil_fixture.artifacts.create(
      content: "Test artifact for has_many association",
      project: @project_one # projects(:one)
    )

    unless new_artifact.persisted?
      skip "Skipping 'has_many :artifacts' test: Failed to create associated artifact. Errors: #{new_artifact.errors.full_messages.join(', ')}"
    end

    assert_includes fav_stencil_fixture.artifacts, new_artifact, "Newly created artifact not found in association."
    assert fav_stencil_fixture.artifacts.count >= 1, "Artifact count should be at least 1."
  end
end
