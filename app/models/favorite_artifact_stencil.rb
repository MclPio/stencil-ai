class FavoriteArtifactStencil < ApplicationRecord
  belongs_to :artifact_stencil
  belongs_to :user
  has_many :artifacts
end
