class ArtifactsController < ApplicationController
  before_action :set_artifact, only: %i[ show edit update destroy ]
  before_action :authorize_user, only: %i[ edit update destroy ]
  before_action :authorize_show, only: %i[ show ]

  def index
    @artifacts = Current.user.artifacts
  end

  def new
    @artifact = Current.user.artifacts.new
  end

  def create
    @artifact = Current.user.artifacts.new(artifact_params)
    if @artifact.save
      redirect_to @artifact
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @artifact.update(artifact_params)
      redirect_to @artifact
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @artifact.destroy
    redirect_to artifacts_path
  end

  private
    def set_artifact
      @artifact = Artifact.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to artifacts_path, alert: "Artifact not found."
    end

    def artifact_params
      params.expect(artifact: [ :name, :content, :prompt, :published ])
    end

    def authorize_user
      return if @artifact.user_id == Current.user.id
      redirect_to artifacts_path, alert: "You are not authorized to perform this action."
    end

    def authorize_show
      return if @artifact.published? || @artifact.user_id == Current.user.id
      redirect_to artifacts_path, alert: "Artifact not found."
    end
end
