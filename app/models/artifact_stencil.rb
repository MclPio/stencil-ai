class ArtifactStencil < ApplicationRecord
  belongs_to :user
  has_many :favorite_artifact_stencils, dependent: :destroy # Added dependent: :destroy for good measure
  has_many :artifacts, through: :favorite_artifact_stencils

  validates :user_id, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :prompt, presence: true # Schema indicates prompt is null: false
end
