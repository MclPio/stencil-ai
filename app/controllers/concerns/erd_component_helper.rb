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
    You are an expert in generating Entity-Relationship Diagrams (ERDs) for Ruby on Rails applications. Your task is to analyze the conversation and produce a valid Mermaid JS ERD diagram that follows Rails Active Record conventions. Follow these rules strictly:

    1. Output *only* valid Mermaid JS ERD syntax (e.g., `erDiagram`, `User ||--o{ Post : "has_many"`).

    2. All relationships must follow Rails Active Record naming conventions and association types:
      - Use `||--o{` for has_many/belongs_to
      - Use `}|--||` for belongs_to/has_one
      - Use `}o--o{` for has_many :through or has_and_belongs_to_many
      - Use `||--||` for has_one/belongs_to
      - Label relationships using exact Active Record macros: "has_many", "belongs_to", "has_one", "has_and_belongs_to_many", "has_many :through"

    3. Ensure table names follow Rails conventions:
      - Model classes are singular and CamelCase (e.g., User, BlogPost)
      - Database tables are plural and snake_case (e.g., users, blog_posts)
      - Association tables use alphabetical naming (e.g., categories_products)
      - Foreign keys follow the pattern singular_model_name_id (e.g., user_id)

    4. Include mandatory fields for Rails models:
      - Primary keys (id)
      - Timestamps (created_at, updated_at)
      - Foreign keys where relevant (e.g., user_id, post_id)

    5. Base the diagram on the conversation's problem statement, models, and specified relationships.

    6. If details are missing, make reasonable assumptions based on Rails conventions and note them in the explanation.

    7. If the user insists on bypassing (e.g., "I've provided enough"), generate a basic Rails-compatible diagram anyway.

    8. Respond *only* with this JSON format, no extra text:
    {
      "mermaid": "erDiagram\\n  User ||--o{ Post : \"has_many\"\\n  Post }o--o{ Tag : \"has_and_belongs_to_many\"\\n...",
      "explanation": "Generated based on X models; assumed Y relationships due to common Rails patterns; added standard Rails fields like Z."
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