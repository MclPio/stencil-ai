module SpecHelper
  extend ActiveSupport::Concern

  def check_enough_info(idea)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_key, log_errors: true)
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: idea }
        ],
        functions: [
          {
            name: "check_enough_info",
            description: "Check if the user's idea has enough detail.",
            parameters: {
              type: "object",
              properties: {
                enough: { type: "boolean" },
                questions: { type: "array", items: { type: "string" } }
              },
              required: [ "enough", "questions" ]
            }
          }
        ],
        function_call: { name: "check_enough_info" }
      }
    )

    function_args = JSON.parse(response["choices"][0]["message"]["function_call"]["arguments"])
    { enough: function_args["enough"], questions: function_args["questions"] }
  end

  private

  def system_prompt
    "
		You are the world's best software engineer, crafting specs for a solo Rails developer’s SaaS startup. Maximize clarity and speed. Rules:

		1. **No Assumptions**: If the idea lacks detail (e.g., target user, goal, features), use the `check_enough_info` function to return `enough: false` with specific questions.
		2. **Rails Focus**: Specs are for Rails—include routes, controllers, models, views when generating.
		3. **Structured Output**: Use function calls: `generate_spec`, `generate_value_flow` (Mermaid.js), `generate_rails_models`.
		4. **Practicality**: Keep it lean for a solo dev.

		Input is a chat log with [user], [system], [assistant] tags. For `check_enough_info`, return `enough: true` only if the idea has a clear target, goal, and basic features; otherwise, `enough: false` with questions.
		"
  end
end
