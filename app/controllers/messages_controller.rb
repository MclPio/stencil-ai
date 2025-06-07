class MessagesController < ApplicationController
  include ConversationHelper
  include ToastHelper

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
      # THIS IS TECHNICAL DEBT
      if params[:message][:artifact_stencil_ids].present? && params[:message][:artifact_stencil_ids].reject(&:blank?).any?
        params[:message][:artifact_stencil_ids].first.split(',').map(&:to_i).each do |id|
          MermaidJob.perform_later(message_params[:conversation_id], id)
        end
      else
        ProcessLlmChatJob.perform_later(message_params[:conversation_id])
      end
    else
      if @message.errors[:base].include?("Conversation has exceeded the token limit of #{Conversation::TOKEN_LIMIT}")
        Turbo::StreamsChannel.broadcast_replace_to(
          "conversation_#{@message.conversation_id}",
          target: "conversation-message-form",
          partial: "conversations/message_form_disabled",
          locals: { conversation: @message.conversation}
        )
      end
      ToastHelper.show_toast("conversation_#{message_params[:conversation_id]}", "error", "Error",  @message.errors.full_messages.join(", "), 8000)
    end
  end

  private

  def message_params
    params.expect(message: [ :content, :conversation_id ])
  end
end
