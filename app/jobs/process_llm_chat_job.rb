class ProcessLlmChatJob < ApplicationJob
  include GeneralChatHelper
  queue_as :default

  def perform(conversation_id)
    response = check_enough_info(conversation_id)
    # { error: true, message: "Service unavailable" }
    # { error: false, content: response.dig("choices", 0, "message", "content") }

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
