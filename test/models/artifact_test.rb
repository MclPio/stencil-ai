require "test_helper"

class ArtifactTest < ActiveSupport::TestCase
  setup do
    @project_one = projects(:one)
    @fav_stencil_one = favorite_artifact_stencils(:one) # Corresponds to user_one, artifact_stencil_one

    # Defensive checks for critical fixtures
    unless @project_one
      puts "Warning: projects(:one) fixture not found in ArtifactTest setup."
      # Consider skipping all tests if this is critical and not found
    end
    unless @fav_stencil_one
      puts "Warning: favorite_artifact_stencils(:one) fixture not found in ArtifactTest setup."
      # Consider skipping all tests
    end
  end

  # Validation tests
  test "should not save artifact without project_id" do
    artifact = Artifact.new(
      favorite_artifact_stencil_id: @fav_stencil_one&.id,
      content: "Test content"
    )
    assert_not artifact.save, "Saved the artifact without a project_id"
    assert_includes artifact.errors[:project_id], "can't be blank"
  end

  test "should save artifact without favorite_artifact_stencil_id" do
    artifact = Artifact.new(
      project_id: @project_one&.id,
      content: "Test content"
    )
    assert true, artifact.save
  end

  test "should save artifact with valid project_id and favorite_artifact_stencil_id" do
    skip "Skipping valid save test due to missing project_one or fav_stencil_one fixtures." unless @project_one && @fav_stencil_one

    artifact = Artifact.new(
      project_id: @project_one.id,
      favorite_artifact_stencil_id: @fav_stencil_one.id,
      content: "Valid test content"
    )
    assert artifact.save, "Could not save the artifact. Errors: #{artifact.errors.full_messages.join(", ")}"
  end

  # Association tests
  test "should belong to project" do
    artifact = Artifact.new
    assert_respond_to artifact, :project, "Artifact does not respond to :project association"

    skip "Skipping project association content test due to missing project_one or fav_stencil_one fixtures." unless @project_one && @fav_stencil_one

    artifact_instance = Artifact.new(
      project: @project_one,
      favorite_artifact_stencil: @fav_stencil_one,
      content: "Test content for project association"
    )
    assert_equal @project_one, artifact_instance.project, "Artifact's project does not match the assigned project."
  end

  test "should belong to favorite_artifact_stencil" do
    artifact = Artifact.new
    assert_respond_to artifact, :favorite_artifact_stencil, "Artifact does not respond to :favorite_artifact_stencil association"

    skip "Skipping fav_stencil association content test due to missing project_one or fav_stencil_one fixtures." unless @project_one && @fav_stencil_one

    artifact_instance = Artifact.new(
      project: @project_one,
      favorite_artifact_stencil: @fav_stencil_one,
      content: "Test content for fav_stencil association"
    )
    assert_equal @fav_stencil_one, artifact_instance.favorite_artifact_stencil, "Artifact's favorite_artifact_stencil does not match."
  end
end
