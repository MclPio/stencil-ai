class Artifact < ApplicationRecord
  belongs_to :project
  belongs_to :favorite_artifact_stencil
  belongs_to :artifact_stencil
end
