class Message < ApplicationRecord
  enum :role, { user: 0, assistant: 1, system: 2 }, default: :user

  belongs_to :conversation

  validates :role, presence: true
  validates :content, presence: true
  validate :below_token_limit

  private

  def below_token_limit
    conversation.total_token.total <= 96000
  end
end
