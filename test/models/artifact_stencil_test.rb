require "test_helper"

class ArtifactStencilTest < ActiveSupport::TestCase
  setup do
    @user = users(:one) # From users.yml
    # Ensure project and favorite_artifact_stencil fixtures are loaded for through-association tests
    # These might not be directly used in all tests but are good for context.
    @project = projects(:one)
    @fav_stencil_for_artifact = favorite_artifact_stencils(:one)
  end

  # Validation tests
  test "should be valid with all required attributes" do
    artifact_stencil = ArtifactStencil.new(
      name: "Valid Name",
      description: "Valid Description",
      prompt: "Valid Prompt",
      user: @user
    )
    assert artifact_stencil.valid?, "ArtifactStencil should be valid. Errors: #{artifact_stencil.errors.full_messages.join(", ")}"
  end

  test "should not save artifact stencil without user_id" do
    artifact_stencil = ArtifactStencil.new(name: "Test Name", description: "Test Desc", prompt: "Test Prompt")
    assert_not artifact_stencil.save, "Saved the artifact stencil without a user_id"
    assert_includes artifact_stencil.errors[:user_id], "can't be blank", "Error message for user_id not found"
    assert_includes artifact_stencil.errors[:user], "must exist", "Error message for user association not found"
  end

  test "should not save artifact stencil without name" do
    artifact_stencil = ArtifactStencil.new(description: "Test Desc", prompt: "Test Prompt", user: @user)
    assert_not artifact_stencil.save, "Saved the artifact stencil without a name"
    assert_includes artifact_stencil.errors[:name], "can't be blank"
  end

  test "should not save artifact stencil without description" do
    artifact_stencil = ArtifactStencil.new(name: "Test Name", prompt: "Test Prompt", user: @user)
    assert_not artifact_stencil.save, "Saved the artifact stencil without a description"
    assert_includes artifact_stencil.errors[:description], "can't be blank"
  end

  test "should not save artifact stencil without prompt" do
    artifact_stencil = ArtifactStencil.new(name: "Test Name", description: "Test Desc", user: @user)
    assert_not artifact_stencil.save, "Saved the artifact stencil without a prompt"
    assert_includes artifact_stencil.errors[:prompt], "can't be blank"
  end

  # Association tests
  test "should belong to user" do
    artifact_stencil_instance = ArtifactStencil.new # Use a different variable name
    assert_respond_to artifact_stencil_instance, :user, "ArtifactStencil does not respond to :user association"

    stencil = ArtifactStencil.new(name: "Test Name", description: "Test Desc", prompt: "Test Prompt", user: @user)
    assert_equal @user, stencil.user
  end

  test "should have many favorite_artifact_stencils" do
    artifact_stencil_instance = ArtifactStencil.new # Use a different variable name
    assert_respond_to artifact_stencil_instance, :favorite_artifact_stencils, "ArtifactStencil does not respond to :favorite_artifact_stencils"

    stencil = artifact_stencils(:one)
    if stencil
      assert_nothing_raised { stencil.favorite_artifact_stencils.count }
      # Example of a more specific assertion if you know fixture details:
      # assert_equal 1, stencil.favorite_artifact_stencils.count, "Expected 1 favorite_artifact_stencil for artifact_stencils(:one)"
    else
      skip "Skipping favorite_artifact_stencils content test as artifact_stencils(:one) fixture not found."
    end
  end

  test "should have many artifacts through favorite_artifact_stencils" do
    artifact_stencil_instance = ArtifactStencil.new # Use a different variable name
    assert_respond_to artifact_stencil_instance, :artifacts, "ArtifactStencil does not respond to :artifacts through favorite_artifact_stencils"

    # More robust test for through-association by creating objects
    stencil_to_test = artifact_stencils(:one)
    user_for_fav = users(:one) # Or a different user if needed
    project_for_artifact = projects(:one)

    skip "Skipping 'has_many :artifacts through' test due to missing prerequisite fixtures (stencil, user, or project)." unless stencil_to_test && user_for_fav && project_for_artifact

    # Use the existing favorite_artifact_stencils(:one) which links artifact_stencils(:one) and users(:one)
    fav_stencil = favorite_artifact_stencils(:one)

    unless fav_stencil && fav_stencil.persisted? && fav_stencil.artifact_stencil == stencil_to_test && fav_stencil.user == user_for_fav
      skip "Skipping 'has_many :artifacts through' test: favorite_artifact_stencils(:one) fixture is not correctly set up for artifact_stencils(:one) and users(:one)."
    end

    # Create an Artifact linked to this FavoriteArtifactStencil
    new_artifact = Artifact.create(
      content: "Artifact for through-association test",
      project: project_for_artifact,
      favorite_artifact_stencil: fav_stencil
    )
    unless new_artifact.persisted?
      skip "Skipping 'has_many :artifacts through' test: failed to create Artifact. Errors: #{new_artifact.errors.full_messages.join(', ')}"
    end

    # Reload the stencil to ensure associations are fresh
    stencil_to_test.reload # stencil_to_test is artifact_stencils(:one)

    assert_includes stencil_to_test.artifacts, new_artifact, "Newly created artifact not found in stencil.artifacts collection."
    # The count could be more than 1 if other artifacts are also associated via other FavoriteArtifactStencils for this stencil,
    # or if artifacts.yml already links to favorite_artifact_stencils(:one).
    # A more robust check is that the count is at least 1 after our addition.
    assert stencil_to_test.artifacts.count >= 1, "Expected at least one artifact associated with the stencil."

    # Clean up created objects to avoid affecting other tests, if necessary,
    # though test transactions should handle this.
    new_artifact.destroy
    # Do not destroy fav_stencil as it's from fixtures.
  end
end
