class ProcessLlmResponseJob < ApplicationJob
  include ConversationHelper
  include ToastHelper
  queue_as :default

  def perform(conversation_id)
    response = check_enough_info(conversation_id)

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      Conversation.find(conversation_id).total_token.update(total: response[:tokens])

      assistant_message = Message.create!(
        role: "assistant",
        content: response[:explanation],
        suggestions: response[:suggestions],
        conversation_id: conversation_id
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation_id}",
        target: "conversations",
        partial: "conversations/assistant_role",
        locals: { message: assistant_message }
      )

      if response[:enough]
        GenerateErdDiagramJob.perform_later(conversation_id)
        # GenerateTopLevelRoadMapJob.perform_later(conversation_id)
        # GenerateValueFlowDiagramJob.perform_later(conversation_id)
      end

    end
  end
end
