module ConversationHelper
  extend ActiveSupport::Concern

  def check_enough_info(conversation_id)
    client = OpenRouterClient.new

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: "Evaluate the SaaS product idea from the conversation so far." }
    ] + message_history

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
              "enough": {
                "type": "boolean",
                "description": "If enough information has been provided by the chat or the user requested to bypass"
              },
              "explanation": {
                "type": "string",
                "description": "A brief reason why it’s enough or what’s missing."
              },
              "suggestions": {
                "type": "string",
                "description": "A list of 1-3 simple, actionable questions or prompts to fill gaps (e.g., 'What’s your timeline for this?'), or an empty array if enough."
              }
            },
            "required": ["enough"],
            "additionalProperties": false
          }
        }
      }
    )
    parse_response(response)
  end

  private

  def system_prompt
    <<~PROMPT
    You are an assistant helping a solo Rails developer refine their SaaS product idea. Analyze the conversation and determine if it has enough detail to generate an architecture diagram and roadmap based on:
    1. A clear problem statement (what issue the product solves).
    2. At least 2-3 key features or functionalities.
    3. Basic technical requirements (e.g., tech stack or integrations).

    Additionally, check if the user has provided useful context like:
    - Time goals (e.g., "I need it in 3 months").
    - Priorities or constraints (e.g., "MVP fast" or "backend-first").

    If the user says they’ve provided enough or wants to bypass this check, set "enough" to true and note their preference in the explanation. Otherwise, be flexible and helpful—don’t block them if they’re close, but guide them toward clarity.

    Respond with a JSON object:
    {
      "enough": true or false,
      "explanation": "A brief reason why it’s enough or what’s missing.",
      "suggestions": ["A list of 1-3 simple, actionable questions or prompts to fill gaps (e.g., 'What’s your timeline for this?'), or an empty array if enough."]
    }

    Keep suggestions concise and relevant—focus on what’s most critical for a solo Rails dev to move forward. Avoid overwhelming them with too many questions.
    PROMPT
  end

  def parse_response(response)
    content = JSON.parse(response[:content])

    {
      error: response[:error],
      enough: content.dig("enough"),
      explanation: content.dig("explanation"),
      suggestions: content.dig("suggestions"),
      tokens: response[:tokens]
    }
  rescue JSON::ParserError
    { error: true, enough: false, message: "Invalid JSON response" }
  end
end
