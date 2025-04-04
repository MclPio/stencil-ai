module ConversationHelper
  extend ActiveSupport::Concern

  def check_enough_info(conversation_id)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_key, log_errors: true)

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: "Evaluate the SaaS product idea from the conversation so far." }
        ] + message_history,
        temperature: 0.3,
        response_format: { type: "json_object" }
      }
    )

    raw_content = response.dig("choices", 0, "message", "content")
    # puts "Raw LLM Response: #{raw_content}"

    parsed_response = parse_response(raw_content)
    # puts "Parsed Response: #{parsed_response}"
    parsed_response
  end

  private

  def system_prompt
    <<~PROMPT
    You are an assistant helping a solo Rails developer evaluate their SaaS product idea. Analyze the conversation and determine if it has enough detail to generate an architecture diagram based on:
    1. A clear problem statement (what issue the product solves).
    2. At least 2-3 key features or functionalities.
    3. Basic technical requirements (e.g., tech stack or integrations).

    If the user says they’ve provided enough or wants to bypass this check, set "enough" to true and note their preference in the explanation. Otherwise, be helpful, not strict—guide them toward clarity.

    Respond with a JSON object:
    {
      "enough": true or false,
      "explanation": "A brief reason why it’s enough or what’s missing.",
      "suggestions": ["A list of 1-3 specific, actionable ideas to improve the input if not enough, or an empty array if enough."]
    }
  PROMPT
  end

  def parse_response(content)
    parsed = JSON.parse(content, symbolize_names: true)

    {
      enough: parsed[:enough] == true,
      explanation: parsed[:explanation].to_s,
      suggestions: parsed[:suggestions]
    }
  rescue JSON::ParserError
    { enough: false, explanation: "Invalid JSON response: '#{content}'" }
  end
end
