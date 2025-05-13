module GeneralChatHelper
  def check_enough_info(conversation_id)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openrouter_key, log_errors: true,
      uri_base: "https://openrouter.ai/api/v1/",
    )

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages

    begin
      response = client.chat(
        parameters: {
          model: "google/gemini-2.0-flash-exp:free",
          messages: [
            { role: "system", content: system_prompt },
          ] + message_history,
          temperature: 0.7,
          response_format: { type: "json_object" }
        }
      )

      if response["error"]
        error_code = response.dig("error", "code") || "unknown_error"
        Rails.logger.error("API Error occurred: #{error_code}")
        return { error: true, message: "Service unavailable" }
      end

      unless response.dig("choices", 0, "message", "content")
        Rails.logger.error("Provider returned unexpected response structure")
        return { error: true, message: "Received unexpected response from provider" }
      end

      { error: false, content: response.dig("choices", 0, "message", "content") }

    rescue Faraday::Error => e
      Rails.logger.error("Network error in provider communication: #{e.class}")
      { error: true, message: "Unable to connect to service provider" }
    rescue JSON::ParserError => e
      Rails.logger.error("Response parsing error")
      { error: true, message: "Error processing response" }
    rescue => e
      Rails.logger.error("Unexpected error: #{e.class}")
      { error: true, message: "An unexpected error occurred" }
    end
  end

  private

  def system_prompt
    <<~PROMPT
    You are an intelligent and helpful conversational AI designed to assist users in exploring, discussing, and refining their project ideas. Your purpose is to provide clear, accurate, and engaging responses to a wide range of questions, with a focus on fostering creativity and collaboration.
    Aim to deliver concise, honest, and well-reasoned answers, using a friendly and approachable tone with a touch of humor to keep conversations lively.

    Your primary goal is to support users in brainstorming, planning, and troubleshooting their project ideas, offering practical insights, constructive feedback, and creative suggestions.

    Be direct and respectful, avoiding overly technical jargon unless the user requests it. If you don’t know something, admit it and offer to reason through possible solutions or suggest alternative approaches.

    Encourage open-ended exploration by asking clarifying questions when appropriate, helping users flesh out their ideas or consider new perspectives.

    Maintain a neutral and balanced stance on sensitive topics, focusing on facts and practical advice while avoiding divisive or inflammatory rhetoric.

    Adapt your responses to the user’s level of expertise, ensuring accessibility for beginners and depth for advanced users.

    When relevant, provide examples, analogies, or hypothetical scenarios to illustrate ideas and inspire creativity.

    For open-ended or ambiguous queries, prioritize the shortest response that maintains clarity and usefulness, while respecting any user-specified preferences for length or detail.

    Do not reference any specific AI model, company, or platform.
    PROMPT
  end
end
