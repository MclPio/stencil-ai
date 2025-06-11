class Invite < ApplicationRecord
  belongs_to :admin, class_name: "User"
  belongs_to :user, class_name: "User", optional: true

  before_create :generate_code

  invite_code :presence, :uniqueness
  activated :presence
  created_by_id :presence

  private

  def active?
    activated && (expires_at.nil? || expires_at.future?)
  end

  def generate_code
    self.invite_code = SecureRandom.alphanumeric(10)
  end
end
