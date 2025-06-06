class ArtifactStencil < ApplicationRecord
  belongs_to :user
  has_many :favorite_artifact_stencils, dependent: :destroy
  has_many :artifacts

  validates :user_id, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :prompt, presence: true # Schema indicates prompt is null: false

  validate :user_within_stencil_limit, on: :create

  ACCOUNT_TYPE_LIMITS = {
    'free' => 2,
    'paid' => 5,
    'admin' => 20
  }.freeze

  private

  def user_within_stencil_limit
    return unless user

    current_count = user.artifact_stencils.count
    limit = ACCOUNT_TYPE_LIMITS[user.account_type] || 0

    if current_count >= limit
      errors.add(:base, "You've reached your limit of #{limit} artifact stencils for your #{user.account_type} account")
    end
  end
end
