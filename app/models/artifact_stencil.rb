class ArtifactStencil < ApplicationRecord
  belongs_to :user
  has_many :artifacts, through: :favorite_artifact_stencils
end
