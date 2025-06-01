class Artifact < ApplicationRecord
  belongs_to :project
  belongs_to :favorite_artifact_stencil

  validates :project_id, presence: true
  validates :favorite_artifact_stencil_id, presence: true
end
