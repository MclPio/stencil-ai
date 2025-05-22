class GenerateErdDiagramJob < ApplicationJob
  queue_as :default
  include ErdComponentHelper

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    artifact = conversation.project.artifact

    erd_response = generate_erd_model(conversation_id)
    artifact.update(model_erd: erd_response[:mermaid])

    assistant_message = Message.create!(
      role: "assistant",
      content: "ERD diagram generated! View it in your project artifact.\n\nExplanation: #{erd_response[:explanation]}",
      conversation_id: conversation_id
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation_id}",
      target: "conversations",
      partial: "conversations/assistant_role",
      locals: { message: assistant_message }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
        "conversation_#{conversation_id}",
        target: "artifact-open-button",
        html: "<button id='artifact-open-button' data-action='click->artifact#open' data-artifact-target='openButton' class='btn btn-outline btn-primary btn-sm'>
                <svg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke-width='1.5' stroke='currentColor' class='size-6'>
                    <path stroke-linecap='round' stroke-linejoin='round' d='M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18' />
                  </svg>
              </button>",
        locals: { }
      )
  end
end