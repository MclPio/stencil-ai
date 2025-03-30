class MessagesController < ApplicationController
  include ConversationHelper

  def create
    @message = Message.new(message_params)
    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream:
            turbo_stream.append("conversations", partial: "conversations/user_role",
                                                   locals: { message: @message })
        end
        format.html { redirect_to @message.conversation }
      end
      ProcessLlmResponseJob.perform_later(message_params[:conversation_id])
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.expect(message: [ :content, :conversation_id ])
  end
end
