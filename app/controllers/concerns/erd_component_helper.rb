module ErdComponentHelper
  extend ActiveSupport::Concern

  def generate_erd_model(conversation_id)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_key, log_errors: true)
    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: erd_system_prompt },
          { role: "user", content: "Generate a valid Mermaid JS ERD diagram based on the conversation." }
        ] + message_history,
        temperature: 0.2,
        response_format: { type: "json_object" }
      }
    )

    raw_content = response.dig("choices", 0, "message", "content")
    puts "Raw LLM Response: #{raw_content}"

    parsed_response = parse_erd_response(raw_content)
    puts "Parsed Response: #{parsed_response}"
    parsed_response
  end

  private

  def erd_system_prompt
    <<~PROMPT
      You are an expert in generating architecture diagrams for SaaS products. Your task is to analyze the conversation and produce a valid Mermaid JS ERD diagram as JSON. Follow these rules strictly:
      1. Output *only* valid Mermaid JS syntax (e.g., `erDiagram`, `ENTITY ||--o{ RELATION : "description"`).
      2. Base the diagram on the conversation’s problem statement, features, and technical requirements.
      3. If details are missing, make reasonable assumptions and note them in the explanation.
      4. If the user insists on bypassing (e.g., "I’ve provided enough"), generate a basic diagram anyway.
      5. Respond *only* with this JSON format, no extra text:
      {
        "mermaid": "erDiagram\\nENTITY ||--o{ RELATION : \"description\"\\n...",
        "explanation": "Generated based on X; assumed Y due to missing Z."
      }
    PROMPT
  end

  def parse_erd_response(content)
    parsed = JSON.parse(content, symbolize_names: true)
    {
      mermaid: parsed[:mermaid].to_s,
      explanation: parsed[:explanation].to_s.presence || "No explanation provided."
    }
  rescue JSON::ParserError
    { mermaid: "erDiagram\nERROR ||--o{ UNKNOWN : \"Invalid syntax\"", explanation: "Invalid JSON response: '#{content}'" }
  end
end