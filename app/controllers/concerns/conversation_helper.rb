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
      You are an assistant evaluating SaaS product ideas for planning. Analyze the conversation and determine if it has enough detail to generate an architecture diagram based on:
      1. A clear problem statement (what issue the product solves).
      2. At least 2-3 key features or functionalities.
      3. Basic technical requirements (e.g., tech stack or integrations).

      if the user wants to bypass it or says they provided enough then let them pass do not be too strict be helpful.
      Respond with a JSON object:
      {
        "enough": true or false,
        "explanation": "A brief reason why it's enough or what is missing."
      }
    PROMPT
  end

  def parse_response(content)
    parsed = JSON.parse(content, symbolize_names: true)

    {
      enough: parsed[:enough] == true,
      explanation: parsed[:explanation].to_s
    }
  rescue JSON::ParserError
    { enough: false, explanation: "Invalid JSON response: '#{content}'" }
  end
end
