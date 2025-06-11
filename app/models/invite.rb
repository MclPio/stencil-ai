class Invite < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: :created_by_id
  belongs_to :user, class_name: "User", optional: true, foreign_key: :used_by_id

  before_validation :generate_code

  validates :invite_code, presence: true, uniqueness: true
  validates :activated, inclusion: { in: [ true, false ] }
  validates :created_by_id, presence: true

  validate :expires_at_must_be_future, if: -> { expires_at.present? }

  def active?
    activated && (expires_at.nil? || expires_at.future?)
  end

  def deactivate!
    update!(activated: false)
  end

  def self.valid_code?(code)
    find_by(invite_code: code)&.active?
  end

  private

  def generate_code
    self.invite_code = SecureRandom.alphanumeric(10)
  end

  def expires_at_must_be_future
    errors.add(:expires_at, "must be in the future") if expires_at <= Time.current
  end
end
