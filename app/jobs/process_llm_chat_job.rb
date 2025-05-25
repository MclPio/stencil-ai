class ProcessLlmChatJob < ApplicationJob
  include GeneralChatHelper
  include ToastHelper
  queue_as :default

  def perform(conversation_id)
    response = send_conversation_to_chat(conversation_id)

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      Conversation.find(conversation_id).total_token.update(total: response[:tokens])

      assistant_message = Message.create!(
        role: "assistant",
        content: response[:content],
        conversation_id: conversation_id
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation_id}",
        target: "conversations",
        partial: "conversations/assistant_role",
        locals: { message: assistant_message }
      )
    end
  end
end
