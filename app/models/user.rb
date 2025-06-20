class User < ApplicationRecord
  include OpenRouterUsageTracker::Trackable

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :weekly_consumption, dependent: :destroy
  has_many :favorite_artifact_stencils
  has_many :artifacts, through: :favorite_artifact_stencils
  has_many :projects, dependent: :destroy
  has_many :artifact_stencils

  validates :email_address, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  has_many :invites, foreign_key: :created_by_id
  has_one :used_invite, class_name: "Invite", foreign_key: :used_by_id
  attr_accessor :invite_code
  validate :invite_code_must_be_valid, on: :create

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :account_type, { free: 0, paid: 1, admin: 2 }, prefix: true

  validate :under_user_limit, on: :create

  after_create :mark_invite_as_used

  private

  def under_user_limit
    if User.count >= 100
      errors.add(:base, "The app only allows 100 users")
    end
  end

  def invite_code_must_be_valid
    if account_type == "admin"
      return
    end
    unless Invite.valid_code?(invite_code)
      errors.add(:invite_code, "is invalid or expired")
    end
  end

  def mark_invite_as_used
    @invite = Invite.find_by(invite_code: invite_code)
    return unless @invite && persisted?
    @invite.update!(used_by_id: id)
  end
end
