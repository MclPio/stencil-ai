class FavoriteArtifactStencilsController < ApplicationController
  before_action :set_favorite_artifact_stencil, only: %i[ destroy ]
  before_action :authorize_user, only: %i[ destroy ]

  def index
  end

  def create
  end

  def destroy
  end

  private

  def set_favorite_artifact_stencil
    @favorite_artifact_stencil = FavoriteArtifactStencil.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "favorite_artifact_stencil not found."
  end

  def favorite_artifact_stencil_params
    params.expect(favorite_artifact_stencil: [ :artifact_stencil_id, :user_id ])
  end

  def authorize_user
    return if @favorite_artifact_stencil.user_id == Current.user.id
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
