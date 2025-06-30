class ProcessLlmChatJob < ApplicationJob
  include GeneralChatHelper
  include ToastHelper
  queue_as :default

  def perform(conversation_id, current_user)
    response = send_conversation_to_chat(conversation_id)

    if response["error"]
      ToastHelper.show_toast("conversation_#{conversation_id}", response.dig("error", "type"),
                             response.dig("error", "code"), response.dig("error", "message"), 8000)
    else
      begin
        OpenRouterUsageTracker.log(response: response, user: current_user)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Failed to log OpenRouter usage: #{e.message}"
      end

      assistant_message = Message.create!(
        role: "assistant",
        content: response.dig("choices", 0, "message", "content"),
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
