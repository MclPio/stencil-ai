class GenerateValueFlowDiagramJob < ApplicationJob
  queue_as :default
  include ValueFlowDiagramHelper

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    spec = conversation.project.spec

    value_flow_diagram_response = generate_value_flow_diagram(conversation_id)
    spec.update(value_flow_diagram: value_flow_diagram_response[:mermaid])

    assistant_message = Message.create!(
      role: "assistant",
      content: "Value Flow generated! View it in your project spec.\n\nExplanation: #{value_flow_diagram_response[:explanation]}",
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
