class GenerateTopLevelRoadMapJob < ApplicationJob
  queue_as :default
  include TopLevelRoadMapHelper
  include ToastHelper

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    artifact = conversation.project.artifact

    response = generate_top_level_roadmap(conversation_id)

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      Conversation.find(conversation_id).total_token.update(total: response[:tokens])
      artifact.update(top_level_roadmap_diagram: response[:mermaid])

      assistant_message = Message.create!(
        role: "assistant",
        content: "Roadmap generated! View it in your project artifact.\n\nExplanation: #{response[:explanation]}",
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
