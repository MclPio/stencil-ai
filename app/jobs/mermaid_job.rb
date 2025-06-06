class MermaidJob < ApplicationJob
  queue_as :default
  include ToastHelper

  def perform(conversation_id, stencil_id)
    response = generate_mermaid_diagram(conversation_id, stencil_id)
    artifact = Project.find

    if response[:error]
      ToastHelper.show_toast("conversation_#{conversation_id}", "error", "Error", response[:message], 8000)
    else
      Conversation.find(conversation_id).total_token.update(total: response[:tokens])

      artifact.update(value_flow_diagram: response[:mermaid])

      assistant_message = Message.create!(
        role: "assistant",
        content: response[:explanation],
        conversation_id: conversation_id
      )

      Turbo::StreamsChannel.broadcast_append_to(
        "conversation_#{conversation_id}",
        target: "conversations",
        partial: "conversations/assistant_role",
        locals: { message: assistant_message }
      )
    end
  end

  def generate_mermaid_diagram(conversation_id, stencil_id)
    client = OpenRouterClient.new
    # stencil = ArtifactStencil.find(stencil_id)
    # stencil_prompt = stencil.prompt
    # stencil_type = stencil.type EXAMPLE: artifact_type (mermaid, text)

    conversation = Conversation.find(conversation_id)
    message_history = conversation.formatted_messages
    messages = [
      { role: "system", content: stencil_prompt },
      { role: "user", content: stencil_description }
    ] + message_history
    # { role: "assistant", content: conversation.artifact} note: old mermaid chart if applicable...

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
            "required": [ "mermaid", "explanation" ],
            "additionalProperties": false
          }
        }
      }
    )

    parse_response(response)
  end

  private

  def value_flow_system_prompt
    <<~PROMPT
    You are an assistant helping a solo Rails developer create a Value Flow Diagram for their SaaS idea. Based on the conversation, generate a Mermaid Flowchart (`graph TD`) mapping how value flows from the user’s problem to the solution, and return it in JSON format.

    Objectives:
    1. Clarity: Include 5-7 key steps, starting with the user’s problem and ending with the delivered value.
    2. Gap-Spotting: Insert a `[TBD - Specify]` node for any unclear critical step.
    3. Key Steps: Highlight 1-2 major value-creating steps using emphasis (e.g., `**bold labels**`) or any Mermaid styling you deem effective.
    4. Rails Context: Use Rails-specific, action-driven labels (e.g., 'User uploads app', 'Controller processes input', 'DB stores data').
    5. Inference: If details are missing, infer logical Rails-relevant steps (e.g., authentication, API calls).

    Rules:
    - Use Mermaid `graph TD` syntax, choosing the best representation for the flow:
      - Select node shapes (e.g., `[square]`, `((circle))`, `(())`, `[/slash/]`, etc.) based on what best conveys the step’s role (e.g., user action, process, outcome).
      - Use arrows (`-->`) with optional `|labels|` (e.g., `-->|processes|`) where it adds clarity.
      - Apply subgraphs (`subgraph`) to group related steps (e.g., app logic) if it improves structure.
    - Format the Mermaid code with newlines (`\n`) for readability (e.g., one statement per line).
    - Avoid oversimplified chains; design an expressive, strategic flow tailored to the idea.
    - Respond *only* with a JSON format (no extra text outside it):
    {
      "mermaid": "graph TD;\n  A[User problem] -->|action| B(Key step);\n  subgraph App;\n    B --> C[Process];\n  end;\n  C --> D(Outcome);",
      "explanation": "Generated from conversation; chose shapes and structure to reflect the SaaS flow."
    }


    Example for a documentation tool:
    {
      "mermaid": "graph TD;\n  A[User has undocumented codebase] -->|uploads| B(User submits Rails app);\n  subgraph App;\n    B --> C[Scan codebase];\n    C -->|analyzes| D[**LLM generates docs**];\n  end;\n  D -->|delivers| E(Docs improve workflow);\n  E --> F[/Export option/];",
      "explanation": "Used squares for user actions, bold for key process, and slash for output to highlight flow."
    }
    PROMPT
  end

  def parse_response(response)
    content = JSON.parse(response[:content])

    {
      error: response[:error],
      explanation: content.dig("explanation"),
      mermaid: content.dig("mermaid"),
      tokens: response[:tokens]
    }
  rescue JSON::ParserError
    { error: true, message: "Invalid JSON response" }
  end
end
