class GenerateSpecJob < ApplicationJob
  queue_as :default

  def perform(project, diagram_types = [:flowchart]) # Default to flowchart
    spec = project.spec || project.spec.create
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_key,
      log_errors: true
    )

    results = {}
    diagram_types.each do |type|
      results[type] = generate_diagram(client, project.idea, type)
    end
    spec.update(user_flow: results[:user_flow], model_erd: results[:model_erd],
                roadmap_flow: results[:roadmap_flow]) # Store based on what's generated
  end

  private

  def generate_diagram(client, idea, type)
    prompt = send("#{type}_prompt")
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "system", content: prompt }, { role: "user", content: idea }],
        tools: [mermaid_tool],
        tool_choice: "required"
      }
    )
    tool_calls = response.dig("choices", 0, "message", "tool_calls")
    return nil unless tool_calls&.any?
    syntax_json = JSON.parse(tool_calls[0].dig("function", "arguments"))
    syntax_json["syntax"]
  end

  def user_flow_prompt
    <<~PROMPT
    Generate a Mermaid.js flowchart (graph TD) showing how a user would use the app.
    Use descriptive nodes (e.g., [Feature Name]) and arrows (-->). No extra text.
    Sample: graph TD\nA[Main System] --> B[Feature 1]\nB --> C[Subtask 1]
    PROMPT
  end

  def erd_prompt
    <<~PROMPT
    Generate a Mermaid.js ERD (erDiagram) showing entity relationships for the app’s data model (e.g., tables, keys, relationships).
    Use ||--o{ for one-to-many, etc. No extra text.
    Sample: erDiagram\nCustomer ||--o{ Order : places\nOrder ||--o{ Item : contains
    PROMPT
  end

  def roadmap_flow_prompt
    <<~PROMPT
    Generate a Mermaid.js ERD (erDiagram) showing the project's roadmap
    Use ||--o{ for one-to-many, etc. No extra text.
    Sample: erDiagram\nCustomer ||--o{ Order : places\nOrder ||--o{ Item : contains
    PROMPT
  end

  def mermaid_tool
    {
      type: "function",
      function: {
        "name": "mermaid_js_syntax",
        "parameters": {
          "type": "object",
          "properties": { "syntax": { "type": "string", "description": "Valid Mermaid JS syntax" } },
          "required": ["syntax"],
          "additionalProperties": false
        },
        "strict": true
      }
    }
  end
end