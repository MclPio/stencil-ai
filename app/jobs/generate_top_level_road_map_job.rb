class GenerateTopLevelRoadMapJob < ApplicationJob
  queue_as :default
  include TopLevelRoadMapHelper

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    spec = conversation.project.spec

    top_level_roadmap_response = generate_top_level_roadmap(conversation_id)
    spec.update(top_level_roadmap_diagram: top_level_roadmap_response[:mermaid])

    assistant_message = Message.create!(
      role: "assistant",
      content: "ERD diagram generated! View it in your project spec.\n\nExplanation: #{top_level_roadmap_response[:explanation]}",
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
