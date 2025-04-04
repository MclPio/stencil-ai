module TopLevelRoadMapHelper
  extend ActiveSupport::Concern

  def generate_top_level_roadmap(conversation_id)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_key, log_errors: true)
    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: top_level_roadmap_system_prompt },
          { role: "user", content: "Generate a valid Mermaid JS roadmap diagram based on the conversation." }
        ] + message_history,
        temperature: 0.2,
        response_format: { type: "json_object" }
      }
    )

    raw_content = response.dig("choices", 0, "message", "content")
    # puts "Raw LLM Response: #{raw_content}"

    parsed_response = parse_top_level_roadmap_response(raw_content)
    # puts "Parsed Response: #{parsed_response}"
    parsed_response
  end

  private

  def top_level_roadmap_system_prompt
    <<~PROMPT
    You are an expert in generating Timeline Diagrams for Ruby on Rails applications. Your task is to analyze the conversation and produce a valid Mermaid JS Timeline Diagram that visualizes a top-level roadmap for the project discussed in the conversation. Follow these rules strictly:

    1. Output *only* valid Mermaid JS Timeline syntax using the timeline format.

    2. Structure the roadmap into clear development phases that follow a typical Rails SaaS development lifecycle:
       - Planning & Setup
       - Core Functionality Development
       - User Experience & UI
       - Testing & Quality Assurance
       - Deployment & Launch
       - Post-Launch Improvements

    3. For each phase, include:
       - Estimated time duration (in weeks)
       - Key milestones and deliverables
       - Critical tasks that must be completed

    4. Use appropriate timeline section organization:
       - Group related tasks under logical sections
       - Include parallel tracks where relevant (e.g., backend/frontend work)
       - Highlight dependencies between milestones

    5. Base the timeline on:
       - The conversation's problem statement
       - The models and relationships identified
       - Technical requirements discussed
       - Business goals mentioned

    6. Reflect Rails-specific development sequences:
       - Database schema and migrations before controller logic
       - Core models before auxiliary features
       - Authentication/authorization before user-specific features

    7. If details are missing, make reasonable assumptions based on Rails conventions and note them in the explanation.

    8. Keep the timeline realistic for a solo Rails developer (avoid overly optimistic schedules).

    9. Respond *only* with this JSON format, no extra text:
    {
      "mermaid": "timeline\\n    title Ruby on Rails SaaS Development Roadmap\\n    section Planning & Setup\\n      Database Schema Design: 1 week\\n      User Authentication Setup: 2 weeks\\n    section Core Functionality\\n      User Management: 2 weeks\\n      ...",
      "explanation": "This roadmap outlines a X-month development cycle with Y major phases. Assumptions made include Z. Critical path items are highlighted in the Planning and Core Functionality sections."
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
