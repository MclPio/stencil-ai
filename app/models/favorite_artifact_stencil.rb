class FavoriteArtifactStencil < ApplicationRecord
  belongs_to :artifact_stencil
  belongs_to :user
  has_many :artifacts, dependent: :nullify

  validates :artifact_stencil_id, presence: true
  validates :user_id, presence: true
  validates :artifact_stencil_id, uniqueness: { scope: :user_id, message: "has already been favorited by this user" }

  after_create :add_usage_count
  after_destroy :subtract_usage_count

  private

  def add_usage_count
    artifact_stencil.increment!(:usage_count)
  end

  def subtract_usage_count
    artifact_stencil.decrement!(:usage_count)
  end
end
