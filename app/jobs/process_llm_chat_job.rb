class ProcessLlmChatJob < ApplicationJob
  include GeneralChatHelper
  queue_as :default

  def perform(conversation_id)
    response = send_conversation_to_chat(conversation_id)
    # { error: true, message: "Service unavailable" }
    # { error: false, content: response.dig("choices", 0, "message", "content") }

    if response[:error]
      # TOAST ERROR MESSAGE
      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation_id}",
        target: "toast_container",
        partial: "shared/toast",
        locals: {
          type: "error",
          title: "Error",
          message: response[:message],
          timeout: 8000
        }
      )
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
