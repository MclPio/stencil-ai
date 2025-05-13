class OpenRouterClient
  API_BASE_URL = "https://openrouter.ai/api/v1/"

  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.open_router_key,
      log_errors: true,
      uri_base: API_BASE_URL
    )
  end

  # Generic method to make any chat API call
  def chat(model:, messages:, temperature: 0.7, response_format: nil, max_tokens: nil)
    parameters = {
      model: model,
      messages: messages,
      temperature: temperature
    }

    # Add optional parameters only if they're provided
    parameters[:response_format] = response_format if response_format
    parameters[:max_tokens] = max_tokens if max_tokens

    begin
      response = @client.chat(parameters: parameters)

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
      Rails.logger.error("Unexpected error: #{e.class}: #{e.message}")
      { error: true, message: "An unexpected error occurred" }
    end
  end
end
