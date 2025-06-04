require "test_helper"

class FavoriteArtifactStencilsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_two = users(:two)
    @other_user = users(:two)
    @artifact_stencil = artifact_stencils(:one)
    @artifact_stencil_two = artifact_stencils(:two)
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
    post session_url, params: { email_address: @user.email_address, password: "1234" }
    assert_difference "FavoriteArtifactStencil.count", 1 do
      post favorite_artifact_stencils_url, params: {
        favorite_artifact_stencil: {
          artifact_stencil_id: @artifact_stencil_two.id,
          user_id: @user.id
        }
      }
    end
    assert_redirected_to favorite_artifact_stencils_path
    assert_equal "Stencil added.", flash[:notice]
  end

  test "should not create favorite_artifact_stencil with invalid params" do
    post session_url, params: { email_address: @user.email_address, password: "1234" }
    assert_no_difference "FavoriteArtifactStencil.count" do
      post favorite_artifact_stencils_url, params: {
        favorite_artifact_stencil: {
          artifact_stencil_id: nil,
          user_id: @user.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should redirect to root if user is not authenticated for create" do
    post favorite_artifact_stencils_url, params: {
      favorite_artifact_stencil: {
        artifact_stencil_id: @artifact_stencil.id,
        user_id: @user.id
      }
    }
    assert_redirected_to new_session_path
  end

  # Tests for the destroy action
  test "should destroy favorite_artifact_stencil for authorized user" do
    post session_url, params: { email_address: @user.email_address, password: "1234" }

    favorite_artifact_stencil = favorite_artifact_stencils(:one)

    assert_difference "FavoriteArtifactStencil.count", -1 do
      delete favorite_artifact_stencil_url(favorite_artifact_stencil)
    end
    assert_redirected_to favorite_artifact_stencils_url
    assert_equal "Stencil removed successfully.", flash[:notice]
  end

  test "should not destroy favorite_artifact_stencil if user is not authorized" do
    post session_url, params: { email_address: @user.email_address, password: "1234" }
    favorite_artifact_stencil = favorite_artifact_stencils(:two)

    assert_no_difference "FavoriteArtifactStencil.count" do
      delete favorite_artifact_stencil_url(favorite_artifact_stencil)
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should redirect to root if favorite_artifact_stencil not found" do
    post session_url, params: { email_address: @user.email_address, password: "1234" }

    delete favorite_artifact_stencil_url(id: 9999)
    assert_redirected_to root_path
    assert_equal "favorite_artifact_stencil not found.", flash[:alert]
  end

  test "should redirect to root if user is not authenticated for destroy" do
    favorite_artifact_stencil = favorite_artifact_stencils(:two)

    delete favorite_artifact_stencil_url(favorite_artifact_stencil)
    assert_redirected_to new_session_path
  end
end
