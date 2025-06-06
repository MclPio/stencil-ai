class Artifact < ApplicationRecord
  belongs_to :project
  belongs_to :favorite_artifact_stencil
  belongs_to :favorite_artifact_stencil_id

  validates :project_id, presence: true
end
