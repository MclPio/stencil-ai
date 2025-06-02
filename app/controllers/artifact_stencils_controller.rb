class ArtifactStencilsController < ApplicationController
  before_action :set_artifact_stencil, only: %i[ show destroy ]
  before_action :authorize_user, only: %i[ destroy ]
  before_action :authorize_show, only: %i[ show ]

  def new
    @artifact_stencil = Current.user.artifact_stencils.new
  end

  def create
    @artifact_stencil = Current.user.artifact_stencils.new(artifact_stencil_params)
    if @artifact_stencil.save
      redirect_to @artifact_stencil
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    @artifact_stencil.destroy
    redirect_to root_path
  end

  private

  def set_artifact_stencil
    @artifact_stencil = ArtifactStencil.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Artifact Stencil not found."
  end

  def artifact_stencil_params
    params.expect(artifact_stencil: [ :name, :description, :prompt, :published ])
  end

  def authorize_user
    return if @artifact_stencil.user_id == Current.user.id
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  def authorize_show
    return if @artifact_stencil.published? || @artifact_stencil.user_id == Current.user.id
    redirect_to root_path, alert: "Artifact not found."
  end
end
