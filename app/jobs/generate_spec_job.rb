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
        messages: [ { role: "user", content: project.idea + value_prop } ],
        temperature: 0.7
      }
    )
    message = response.dig("choices", 0, "message", "content")
    # LLM ENDS
    spec.update(content: message)
  end

  private

  def value_prop
    "
    You will make the value proposition based on the idea attached. You will also make a list of core features.
    "
  end
end
