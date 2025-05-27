class TotalToken < ApplicationRecord
  belongs_to :conversation
  after_save :update_conversation_reached_token_limit

  private

  def update_conversation_reached_token_limit
    conversation.update(reached_token_limit: total > Conversation::TOKEN_LIMIT)
  end
end
