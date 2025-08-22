class ConversationsController < ApplicationController
  before_action :set_project_conversation

  def show
  end

  def artifact
    render partial: "conversations/artifacts/mermaid", locals: { artifact_id: params[:artifact_id] }
  end

  private

  def set_project_conversation
    @project = Project.find(params[:project_id])
    @projects = Current.user.projects
    @conversation = @project.conversation
    # @artifact_stencils = @project.user.
  end
end
