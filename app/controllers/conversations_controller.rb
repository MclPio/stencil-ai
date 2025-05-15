class ConversationsController < ApplicationController
  before_action :set_project_conversation

  def show
  end

  def artifact
    render partial: "conversations/artifacts/#{params[:type]}"
  end

  private

  def set_project_conversation
    @project = Project.find(params[:project_id])
    @projects = Current.user.projects
    @conversation = @project.conversation
    @artifact = @project.artifact
  end
end
