class FavoriteArtifactStencilsController < ApplicationController
  before_action :set_favorite_artifact_stencil, only: %i[ destroy ]
  before_action :authorize_user, only: %i[ destroy ]

  def index
    @favorite_artifact_stencils = FavoriteArtifactStencil.where(user: Current.user).map do |fas|
      [ fas.artifact_stencil.id, fas.artifact_stencil.name, fas.artifact_stencil.description ]
    end
  end

  def create
    @favorite_artifact_stencil = Current.user.favorite_artifact_stencils.new(favorite_artifact_stencil_params)
    if @favorite_artifact_stencil.save
      redirect_to favorite_artifact_stencils_path, notice: "Stencil added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @favorite_artifact_stencil.destroy
    redirect_to favorite_artifact_stencils_path, notice: "Stencil removed successfully."
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
