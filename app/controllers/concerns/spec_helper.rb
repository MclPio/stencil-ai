module SpecHelper
  extend ActiveSupport::Concern

  def check_enough_info(idea)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_key, log_errors: true)
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: idea }
        ]
      }
    )

    parsed_response = parse_response(response["choices"][0]["message"]["content"])
    { enough: parsed_response[:enough], explanation: parsed_response[:explanation] }
  end

  private

  def system_prompt
    <<~PROMPT
      Evaluate the following SaaS product idea and determine if it contains enough detail to generate an architecture diagram.

      Criteria:
      1. A clear problem statement (what issue the product solves).
      2. At least 2-3 key features or functionalities.
      3. Basic technical requirements (e.g., tech stack or integrations).

      Respond in the following JSON format:
      {
        "enough": true/false,
        "explanation": "A brief reason why it's enough or what is missing."
      }
    PROMPT
  end

  def parse_response(content)
    JSON.parse(content, symbolize_names: true)
  rescue JSON::ParserError
    { enough: false, explanation: "Invalid response format from AI." }
  end
end
