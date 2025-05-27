class Message < ApplicationRecord
  enum :role, { user: 0, assistant: 1, system: 2 }, default: :user

  belongs_to :conversation

  validates :role, presence: true
  validates :content, presence: true
  validate :below_token_limit

  private

  def below_token_limit
    if conversation.total_token.total > Conversation::TOKEN_LIMIT
      errors.add(:base, "Conversation has exceeded the token limit of #{Conversation::TOKEN_LIMIT}")
    end
  end
end
