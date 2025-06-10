class MermaidJob < ApplicationJob
  queue_as :default
  include ToastHelper

  def perform(conversation_id, artifact_stencil_id, favorite_artifact_stencil_id)
    response = generate_mermaid_diagram(conversation_id, artifact_stencil_id)
    conversation = Conversation.find(conversation_id)
    artifact = conversation.project.artifacts.find_or_create_by(artifact_stencil_id: artifact_stencil_id, favorite_artifact_stencil_id: favorite_artifact_stencil_id) # add fav id

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      Conversation.find(conversation_id).total_token.update(total: response[:tokens])

      artifact&.update(content: response[:mermaid])

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

      # Turbo::StreamsChannel.broadcast_replace_to(
      #   "conversation_#{conversation_id}",
      #   target: "conversations",
      #   partial: "conversations/artifact_open_button",
      #   locals: {project: conversation.project})
    end
  end

  def generate_mermaid_diagram(conversation_id, artifact_stencil_id)
    client = OpenRouterClient.new
    stencil = ArtifactStencil.find(artifact_stencil_id)
    stencil_prompt = stencil.prompt

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [{ role: "system", content: stencil_prompt }] + message_history

    response = client.chat(
      model: "meta-llama/llama-3.3-8b-instruct:free",
      messages: messages,
      temperature: 0.3,
      usage: { "include": true },
      response_format: {
        "type": "json_schema",
        "json_schema": {
          "name": "info",
          "strict": true,
          "schema": {
            "type": "object",
            "properties": {
              "mermaid": {
                "type": "string",
                "description": "mermaid js code only"
              },
              "explanation": {
                "type": "string",
                "description": "An explanation of the mermaid creation and any additional comments go here"
              }
            },
            "required": [ "mermaid", "explanation" ],
            "additionalProperties": false
          }
        }
      }
    )

    parse_response(response)
  end

  private

  def parse_response(response)
    content = JSON.parse(response[:content])

    {
      error: response[:error],
      explanation: content.dig("explanation"),
      mermaid: content.dig("mermaid"),
      tokens: response[:tokens]
    }
  rescue JSON::ParserError
    { error: true, message: "Invalid JSON response" }
  end

  def query_artifact(conversation, artifact_stencil_id)
    conversation.project.artifacts.find_by(artifact_stencil_id:)&.content
  end
end
