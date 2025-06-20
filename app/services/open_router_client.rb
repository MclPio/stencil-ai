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
  def chat(model:, messages:, temperature: 0.7, response_format: nil, max_tokens: nil, usage: nil)
    parameters = {
      model: model,
      messages: messages,
      temperature: temperature
    }

    # Add optional parameters only if they're provided
    parameters[:response_format] = response_format if response_format
    parameters[:max_tokens] = max_tokens if max_tokens
    parameters[:usage] = usage if usage

    begin
      response = @client.chat(parameters: parameters)

      if response["error"]
        error_code = response.dig("error", "code") || "unknown_error"
        Rails.logger.error("API Error occurred: #{error_code}")
        return response
      end

      unless response.dig("choices", 0, "message", "content")
        Rails.logger.warn("No assistant content in response — may be tool/function call or refusal.")
      end

      unless response.dig("usage", "total_tokens")
        Rails.logger.error("Missing token usage in response")
      end

      response

    rescue Faraday::Error => e
      Rails.logger.error("Network error in provider communication: #{e.class}")
      {
        "error" => {
          "message" => "Unable to connect to service provider",
          "type" => "network_error",
          "code" => e.class.to_s
        }
      }
    rescue JSON::ParserError => e
      Rails.logger.error("Response parsing error: #{e.message}")
      {
        "error" => {
          "message" => "Error processing response",
          "type" => "parse_error",
          "code" => "json_parse_error"
        }
      }
    rescue => e
      Rails.logger.error("Unexpected error: #{e.class}: #{e.message}")
      {
        "error" => {
          "message" => "An unexpected error occurred",
          "type" => "internal_error",
          "code" => e.class.to_s
        }
      }
    end
  end
end
