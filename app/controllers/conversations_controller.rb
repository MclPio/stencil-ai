class ConversationsController < ApplicationController
  def show
    project = Project.find(params[:project_id])
    @conversation = project.conversation.preload(:messages)
  end
end
