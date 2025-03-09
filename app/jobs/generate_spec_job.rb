require "openai"

class GenerateSpecJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    spec = project.specs.last || project.specs.create
    # LLM
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_key,
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
    # LLM ENDS
    spec.update(content: "Generated spec from: #{project.idea}")
  end
end
