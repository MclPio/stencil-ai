require "openai"

class GenerateSpecJob < ApplicationJob
  queue_as :default

  def perform(project)
    spec = project.specs.last || project.specs.create

    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_key,
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ { role: "system", content: value_flow }, { role: "user", content: project.idea } ],
        tools: [
          {
            type: "function",
            function: {
              "name": "mermaid_js_syntax",
              "parameters": {
                "type": "object",
                "properties": {
                  "syntax": {
                    "type": "string",
                    "description": "A valid Mermaid JS syntax string for rendering diagrams. Ensure correctness and avoid extra explanations."
                  },
                },
                "required": ["syntax"],
                "additionalProperties": false,
              },
              "strict": true,
            },
          }
        ],
        tool_choice: "required"
      }
    )
    message = response.dig("choices", 0, "message", "content")

    if message.nil?
      tool_calls = response.dig("choices", 0, "message", "tool_calls")
      if tool_calls && tool_calls.any?
        mermaid_syntax = tool_calls[0].dig("function", "arguments")
        syntax_json = JSON.parse(mermaid_syntax) # Convert JSON string to Hash
        message = syntax_json["syntax"] # Extract the actual Mermaid.js syntax
      end
    end
    spec.update(content: message)  end

  private

  def value_flow
    <<~PROMPT
    Generate a Mermaid.js flowchart showing how features connect to value (e.g., revenue, user benefit).
    When generating, create a Mermaid.js flowchart (graph TD) that maps the user’s
    features to their value (e.g., revenue, user retention). Keep it concise, use descriptive nodes
    (e.g., [Feature Name]), and arrows (-->), focusing on the app’s core flow.
    Do not include explanations, markdown code fences, or any other text
    Sample output:
    graph TD
    A[Main System] --> B[Feature 1]
    B --> C[Subtask 1]
    A --> D[Feature 2]
    D --> E[Subtask 2]
    D --> F[Subtask 3]
    PROMPT
  end
end
