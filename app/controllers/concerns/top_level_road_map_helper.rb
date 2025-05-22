module TopLevelRoadMapHelper
  extend ActiveSupport::Concern

  def generate_top_level_roadmap(conversation_id)
    client = OpenRouterClient.new
    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [
      { role: "system", content: top_level_roadmap_system_prompt },
      { role: "user", content: "Generate a valid Mermaid JS roadmap diagram based on the conversation, adapting to any time goals or constraints mentioned." }
    ] + message_history

    response = client.chat(
      model: "meta-llama/llama-3.3-8b-instruct:free",
      messages: messages,
      temperature: 0.3,
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

    raw_content = response[:content]
    # puts "Raw LLM Response: #{raw_content}"

    parsed_response = parse_top_level_roadmap_response(raw_content)
    # puts "Parsed Response: #{parsed_response}"
    parsed_response
  end

  private

  def top_level_roadmap_system_prompt
    <<~PROMPT
    You are an expert in generating Timeline Diagrams for Ruby on Rails applications. Your task is to analyze the conversation and produce a valid Mermaid JS Timeline Diagram that visualizes a top-level roadmap for the project, tailored to the user's specific goals and constraints. Follow these rules:

    1. Output *only* valid Mermaid JS Timeline syntax using the timeline format.

    2. Structure the roadmap dynamically based on:
       - The user's stated time goals (e.g., "I need this in 3 months") or default to a 3-month solo-dev timeline if unspecified.
       - Key priorities or constraints (e.g., "MVP for a demo," "backend-first," "no UI needed").
       - The problem statement, models, technical requirements, and business goals from the conversation.

    3. Generate phases that fit the project’s needs, such as:
       - Planning & Setup
       - Core Functionality Development
       - User Experience & UI (if relevant)
       - Testing & Quality Assurance
       - Deployment & Launch
       - Post-Launch Improvements (optional)
       - Omit or combine phases if they don’t apply (e.g., skip UI for an API app).

    4. For each phase, include:
       - Estimated time duration (in weeks, adjusted to fit the user’s timeline)
       - Key milestones and deliverables
       - Critical tasks, reflecting Rails conventions (e.g., schema before controllers)

    5. Use appropriate timeline section organization:
       - Group related tasks under logical sections
       - Include parallel tracks where feasible (e.g., backend/frontend)
       - Highlight dependencies between milestones

    6. If the user’s time goal is aggressive, note trade-offs (e.g., reduced testing or scope).
    7. If details are missing, make reasonable assumptions based on Rails conventions and the solo-dev context, and explain them.

    8. Respond *only* with this JSON format:
    {
      "mermaid": "timeline\\n    title Ruby on Rails SaaS Development Roadmap\\n    section Planning & Setup\\n      Database Schema Design: 1 week\\n      User Authentication Setup: 1 week\\n    section Core Functionality\\n      Core Feature X: 2 weeks\\n      ...",
      "explanation": "This roadmap adapts to a [X]-month goal based on [user input]. Phases are tailored to [priorities]. Assumptions: [Y]. Trade-offs: [Z]."
    }
    PROMPT
  end

  def parse_top_level_roadmap_response(content)
    parsed = JSON.parse(content, symbolize_names: true)
    {
      mermaid: parsed[:mermaid].to_s,
      explanation: parsed[:explanation].to_s.presence || "No explanation provided."
    }
  rescue JSON::ParserError
    { mermaid: "timeline\ntitle ERROR\nsection Error\n  Invalid JSON response: 1 day", explanation: "Invalid JSON response: '#{content}'" }
  end
end
