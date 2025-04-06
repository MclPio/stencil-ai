class ConversationsController < ApplicationController
  layout "conversation"

  def show
    project = Project.find(params[:project_id])
    @conversation = project.conversation
  end
end
