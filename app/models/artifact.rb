class Artifact < ApplicationRecord
  belongs_to :project
  belongs_to :favorite_artifact_stencil
end
