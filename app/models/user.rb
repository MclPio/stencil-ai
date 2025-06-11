class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :weekly_consumption, dependent: :destroy
  has_many :favorite_artifact_stencils
  has_many :artifacts, through: :favorite_artifact_stencils
  has_many :projects, dependent: :destroy
  has_many :artifact_stencils

  has_many :invites, foreign_key: :created_by_id
  has_one :used_invite, class_name: "Invite", foreign_key: :used_by_id

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :account_type, { free: 0, paid: 1, admin: 2 }, prefix: true

  validate :under_user_limit, on: :create

  private

  def under_user_limit
    if User.count >= 100
      errors.add(:base, "The app only allows 100 users")
    end
  end
end
