class ContentGenerationJob < ApplicationJob
  queue_as :default
  include ToastHelper

  def perform(conversation_id, artifact_stencil_id, favorite_artifact_stencil_id, current_user)
    response = generate_content(conversation_id, artifact_stencil_id)
    conversation = Conversation.find(conversation_id)
    artifact = conversation.project.artifacts.find_or_create_by(
      artifact_stencil_id: artifact_stencil_id,
      favorite_artifact_stencil_id: favorite_artifact_stencil_id
    )

    if response["error"]
      show_error_toast(conversation_id, response["error"])
    else
      handle_successful_response(response, conversation, artifact, current_user, artifact_stencil_id)
    end
  end

  private

  def generate_content(conversation_id, artifact_stencil_id)
    client = OpenRouterClient.new
    stencil = ArtifactStencil.find(artifact_stencil_id)

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [ { role: "system", content: stencil.prompt } ] + message_history

    client.chat(
      model: "google/gemini-2.5-flash-lite-preview-06-17",
      messages: messages,
      temperature: determine_temperature(stencil),
      usage: { "include": true },
      response_format: build_response_format(stencil)
    )
  end

  def determine_temperature(stencil)
    stencil.mermaid? ? 0.3 : 0.7
  end

  def build_response_format(stencil)
    content_key = stencil.mermaid? ? "mermaid" : "content"
    content_description = stencil.mermaid? ? "mermaid js code only" : "your response to the query"

    {
      "type": "json_schema",
      "json_schema": {
        "name": "info",
        "strict": true,
        "schema": {
          "type": "object",
          "properties": {
            content_key => {
              "type": "string",
              "description": content_description
            },
            "explanation" => {
              "type": "string",
              "description": "An explanation of the response and any additional comments go here"
            }
          },
          "required": [ content_key, "explanation" ],
          "additionalProperties": false
        }
      }
    }
  end

  def parse_response(response, stencil)
    content_string = response.dig("choices", 0, "message", "content")
    content_json = JSON.parse(content_string)

    # Determine the content key based on stencil type
    content_key = stencil.mermaid? ? "mermaid" : "content"

    {
      content: content_json[content_key],
      explanation: content_json["explanation"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse LLM JSON content: #{e.message}")
    nil
  end

  def handle_successful_response(response, conversation, artifact, current_user, artifact_stencil_id)
    log_usage(response, current_user)

    stencil = ArtifactStencil.find(artifact_stencil_id)
    parsed = parse_response(response, stencil)

    unless parsed
      show_parse_error_toast(conversation.id)
      return
    end

    update_artifact_and_broadcast(artifact, parsed, conversation)
  end

  def log_usage(response, current_user)
    OpenRouterUsageTracker.log(response: response, user: current_user)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to log OpenRouter usage: #{e.message}"
  end

  def update_artifact_and_broadcast(artifact, parsed, conversation)
    artifact&.update(content: parsed[:content])

    assistant_message = Message.create!(
      role: "assistant",
      content: parsed[:explanation],
      conversation_id: conversation.id
    )

    broadcast_message(conversation.id, assistant_message)
    broadcast_artifact_updates(conversation)
  end

  def broadcast_message(conversation_id, message)
    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation_id}",
      target: "conversations",
      partial: "conversations/assistant_role",
      locals: { message: message }
    )
  end

  def broadcast_artifact_updates(conversation)
    conversation_id = conversation.id

    # Broadcast artifact open button update
    Turbo::StreamsChannel.broadcast_replace_to(
      "conversation_#{conversation_id}",
      target: "artifact-open-button",
      partial: "conversations/artifact_open_button",
      locals: { project: conversation.project }
    )

    # Broadcast artifact selection update
    Turbo::StreamsChannel.broadcast_replace_to(
      "conversation_#{conversation_id}",
      target: "artifact-selection",
      partial: "conversations/artifact_selection",
      locals: { project: conversation.project }
    )
  end

  def show_error_toast(conversation_id, error)
    ToastHelper.show_toast(
      "conversation_#{conversation_id}",
      error["type"],
      error["code"],
      error["message"],
      8000
    )
  end

  def show_parse_error_toast(conversation_id)
    ToastHelper.show_toast(
      "conversation_#{conversation_id}",
      "invalid_response",
      "json_parse_error",
      "Invalid format from LLM response.",
      8000
    )
  end
end
