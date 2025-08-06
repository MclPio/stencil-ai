class MermaidJob < ApplicationJob
  queue_as :default
  include ToastHelper

  def perform(conversation_id, artifact_stencil_id, favorite_artifact_stencil_id, current_user)
    response = generate_mermaid_diagram(conversation_id, artifact_stencil_id)
    conversation = Conversation.find(conversation_id)
    artifact = conversation.project.artifacts.find_or_create_by(artifact_stencil_id: artifact_stencil_id, favorite_artifact_stencil_id: favorite_artifact_stencil_id) # add fav id

    if response["error"]
      ToastHelper.show_toast("conversation_#{conversation_id}", response.dig("error", "type"),
                        response.dig("error", "code"), response.dig("error", "message"), 8000)
    else
      begin
        OpenRouterUsageTracker.log(response: response, user: current_user)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Failed to log OpenRouter usage: #{e.message}"
      end

      parsed = parse_response(response)
      unless parsed
        ToastHelper.show_toast("conversation_#{conversation_id}", "invalid_response", "json_parse_error", "Invalid format from LLM response.", 8000)
        return
      end

      artifact&.update(content: parsed[:mermaid])

      assistant_message = Message.create!(
        role: "assistant",
        content: parsed[:explanation],
        conversation_id: conversation_id
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation_id}",
        target: "conversations",
        partial: "conversations/assistant_role",
        locals: { message: assistant_message }
      )

      Turbo::StreamsChannel.broadcast_replace_to( # SHOULD ONLY HAPPEN WHEN THERE WERE NO PREVIOUS ARTIFACTS
        "conversation_#{conversation_id}",
        target: "artifact-open-button",
        partial: "conversations/artifact_open_button",
        locals: { project: conversation.project }
      )

      Turbo::StreamsChannel.broadcast_replace_to( # DOES NOT REFETCH CONTENT!
        "conversation_#{conversation_id}",
        target: "artifact-selection",
        partial: "conversations/artifact_selection",
        locals: { project: conversation.project }
      )
    end
  end

  def generate_mermaid_diagram(conversation_id, artifact_stencil_id)
    client = OpenRouterClient.new
    stencil = ArtifactStencil.find(artifact_stencil_id)
    stencil_prompt = stencil.prompt

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [ { role: "system", content: stencil_prompt } ] + message_history

    if stencil.mermaid?
      response = client.chat(
        model: "google/gemini-2.5-flash-lite-preview-06-17",
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
    elsif stencil.regular_text?
      response = client.chat(
        model: "google/gemini-2.5-flash-lite-preview-06-17",
        messages: messages,
        temperature: 0.7,
        usage: { "include": true },
        response_format: {
          "type": "json_schema",
          "json_schema": {
            "name": "info",
            "strict": true,
            "schema": {
              "type": "object",
              "properties": {
                "text": {
                  "type": "string",
                  "description": "your response to the query"
                },
                "explanation": {
                  "type": "string",
                  "description": "An explanation of the response and any additional comments go here"
                }
              },
              "required": [ "info", "explanation" ],
              "additionalProperties": false
            }
          }
        }
      )
    end
    response
  end

  private

  def parse_response(response)
    content_string = response.dig("choices", 0, "message", "content")
    content_json = JSON.parse(content_string)

    {
      mermaid: content_json["mermaid"],
      explanation: content_json["explanation"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse LLM JSON content: #{e.message}")
    nil
  end

  def query_artifact(conversation, artifact_stencil_id)
    conversation.project.artifacts.find_by(artifact_stencil_id:)&.content
  end
end
