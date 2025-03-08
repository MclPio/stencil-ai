class GenerateSpecJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    spec = project.specs.last || project.specs.create
    # Placeholder: Real LLM call goes here later
    spec.update(content: "Generated spec from: #{project.idea}")
  end
end
