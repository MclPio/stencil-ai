require "test_helper"

class FavoriteArtifactStencilsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @artifact_stencil = artifact_stencils(:one)
  end

  test "should get index for authenticated user" do
    post session_url, params: { email_address: @user.email_address, password: "1234" }
    get favorite_artifact_stencils_url
    assert_response :success
  end

  test "should redirect to root if user is not authenticated for index" do
    get favorite_artifact_stencils_url
    assert_response :redirect
  end

  test "should create favorite_artifact_stencil for authenticated user with valid params" do
    assert_difference "FavoriteArtifactStencil.count", 1 do
      post favorite_artifact_stencils_url, params: {
        favorite_artifact_stencil: {
          artifact_stencil_id: @artifact_stencil.id,
          user_id: @user.id
        }
      }
    end
    assert_redirected_to favorite_artifact_stencils_url
    assert_equal "Favorite artifact stencil created successfully.", flash[:notice]
    # Note: Adjust the notice message based on your controller's implementation
  end

  test "should not create favorite_artifact_stencil with invalid params" do
    assert_no_difference "FavoriteArtifactStencil.count" do
      post favorite_artifact_stencils_url, params: {
        favorite_artifact_stencil: {
          artifact_stencil_id: nil, # Invalid because artifact_stencil_id is required
          user_id: @user.id
        }
      }
    end
    # Check for appropriate response (e.g., redirect or render with error)
    assert_response :unprocessable_entity # or :bad_request, depending on your implementation
    assert_equal "Failed to create favorite artifact stencil.", flash[:alert]
    # Note: Adjust the alert message and response status based on your controller
  end

  test "should redirect to root if user is not authenticated for create" do
    Current.user = nil
    post favorite_artifact_stencils_url, params: {
      favorite_artifact_stencil: {
        artifact_stencil_id: @artifact_stencil.id,
        user_id: @user.id
      }
    }
    assert_redirected_to root_path
    assert_equal "You must be logged in to access this page.", flash[:alert]
    # Note: Adjust the alert message to match your authentication logic
  end

  # Tests for the destroy action
  test "should destroy favorite_artifact_stencil for authorized user" do
    assert_difference "FavoriteArtifactStencil.count", -1 do
      delete favorite_artifact_stencil_url(@favorite_artifact_stencil)
    end
    assert_redirected_to favorite_artifact_stencils_url
    assert_equal "Favorite artifact stencil removed successfully.", flash[:notice]
    # Note: Adjust the notice message based on your controller's implementation
  end

  test "should not destroy favorite_artifact_stencil if user is not authorized" do
    Current.user = @other_user
    assert_no_difference "FavoriteArtifactStencil.count" do
      delete favorite_artifact_stencil_url(@favorite_artifact_stencil)
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should redirect to root if favorite_artifact_stencil not found" do
    delete favorite_artifact_stencil_url(id: 9999) # Non-existent ID
    assert_redirected_to root_path
    assert_equal "favorite_artifact_stencil not found.", flash[:alert]
  end

  test "should redirect to root if user is not authenticated for destroy" do
    Current.user = nil
    delete favorite_artifact_stencil_url(@favorite_artifact_stencil)
    assert_redirected_to root_path
    assert_equal "You must be logged in to access this page.", flash[:alert]
    # Note: Adjust the alert message to match your authentication logic
  end
end
