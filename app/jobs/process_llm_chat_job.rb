class ProcessLlmChatJob < ApplicationJob
  include GeneralChatHelper
  include ToastHelper
  queue_as :default

  def perform(conversation_id)
    response = send_conversation_to_chat(conversation_id)
    # { error: true, message: "Service unavailable" }
    # { error: false, content: response.dig("choices", 0, "message", "content") }

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      assistant_message = Message.create!(
        role: "assistant",
        content: response,
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
