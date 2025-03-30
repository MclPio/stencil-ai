class GenerateErdDiagramJob < ApplicationJob
  queue_as :default
  include ErdComponentHelper

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    spec = conversation.project.spec

    erd_response = generate_erd_model(conversation_id)
    spec.update(model_erd: erd_response[:mermaid])

    assistant_message = Message.create!(
      role: "assistant",
      content: "ERD diagram generated! View it in your project spec.\n\nExplanation: #{erd_response[:explanation]}",
      conversation_id: conversation_id
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation_id}",
      target: "conversations",
      partial: "conversations/assistant_role",
      locals: { message: assistant_message }
    )

    conversation.project.spec.update(model_erd: erd_content)
  end
end