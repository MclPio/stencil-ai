class Artifact < ApplicationRecord
  belongs_to :project

  def has_artifacts
    model_erd.present? || user_flow.present? || roadmap_flow.present?
  end
end
