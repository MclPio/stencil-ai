class ProcessLlmResponseJob < ApplicationJob
  include ConversationHelper
  queue_as :default

  def perform(conversation_id)
    response = check_enough_info(conversation_id)

    assistant_message = Message.create!(
      role: "assistant",
      content: response[:explanation],
      conversation_id: conversation_id
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation_id}",
      target: "conversations",
      partial: "conversations/assistant_role",
      locals: { message: assistant_message }
    )

    if response[:enough]
      puts("######## RESPONSE IS ENOUGH TO TRIGGER ERD GENERATE")
      # GenerateErdDiagramJob.perform_later(conversation_id)
    end
  end
end
