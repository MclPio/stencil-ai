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

      # if response[:enough]
        # run the erd diagram component job.
        # notify user when done via assistant message...
        # user clicks spec to view it
      # end

      # assistant_chat(conversation_id)
      #   check_enough_info
      #   save message in conversation Message.create!(role: "assistant", content: content)

      # if Conversation.find(conversation_id).messages.last.enough (should be the assistant)
      #  call spec job and generate marmaid erd
      # else
      #  do nothing and keep chatting
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
