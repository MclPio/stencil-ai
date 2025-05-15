class ArtifactsController < ApplicationController
  def show
    @artifact = Project.find(params[:project_id]).artifact
  end
end
