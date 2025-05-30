class Project < ApplicationRecord
  belongs_to :user
  has_one :artifact, dependent: :destroy
  has_one :conversation, dependent: :destroy

  validate :validate_project_limit_for_user, on: :create

  after_create -> { create_conversation; create_artifact }

  private

  def validate_project_limit_for_user
    return unless user # Ensure there's a user associated

    project_count = user.projects.count

    case user.account_type
    when "free"
      if project_count >= 1
        errors.add(:base, "Free users are limited to 1 project.")
      end
    when "paid"
      if project_count >= 10
        errors.add(:base, "Paid users are limited to 10 projects.")
      end
    when "admin"
      if project_count >= 10 # Assuming admin users also have a limit, as per the prompt.
        errors.add(:base, "Admin users are limited to 10 projects.")
      end
    end
  end
end
