class Invite < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: :created_by_id
  belongs_to :user, class_name: "User", optional: true, foreign_key: :used_by_id

  before_validation :generate_code, on: :create
  before_destroy :ensure_destroyable

  validates :invite_code, presence: true, uniqueness: true
  validates :created_by_id, presence: true

  validate :expires_at_must_be_future, if: -> { expires_at.present? }

  def active?
    used_by_id.nil? && (expires_at.nil? || expires_at.future?)
  end

  def self.valid_code?(code)
    find_by(invite_code: code)&.active?
  end

  private

  def generate_code
    self.invite_code = SecureRandom.alphanumeric(10) if invite_code.blank?
  end

  def expires_at_must_be_future
    errors.add(:expires_at, "must be in the future") if expires_at <= Time.current
  end

  def ensure_destroyable
    if used_by_id.present?
      errors.add(:base, "Cannot delete invite code that has been used by a registered user")
      throw(:abort)
    end
  end
end
