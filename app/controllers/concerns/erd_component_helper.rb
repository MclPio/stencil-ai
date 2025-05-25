module ErdComponentHelper
  extend ActiveSupport::Concern

  def generate_erd_model(conversation_id)
    client = OpenRouterClient.new
    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [
      { role: "system", content: erd_system_prompt },
      { role: "user", content: "Generate a valid Mermaid JS ERD diagram based on the conversation." }
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
              "mermaid": {
                "type": "string",
                "description": "mermaid js code only"
              },
              "explanation": {
                "type": "string",
                "description": "An explanation of the mermaid creation and any additional comments go here"
              }
            },
            "required": ["mermaid", "explanation"],
            "additionalProperties": false
          }
        }
      }
    )

    parse_response(response)
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

  def parse_response(response)
    content = JSON.parse(response[:content])

    {
      error: response[:error],
      enough: content.dig("enough"),
      explanation: content.dig("explanation"),
      mermaid: content.dig("mermaid"),
      tokens: response[:tokens]
    }
  rescue JSON::ParserError
    { error: true, enough: false, message: "Invalid JSON response" }
  end
end
