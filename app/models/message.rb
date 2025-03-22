class Message < ApplicationRecord
  enum :role, { user: 0, assistant: 1, system: 2 }, default: :user

  belongs_to :conversation

  validates :role, presence: true
  validates :content, presence: true

  after_create :update_conversation_token_counts

  private

  def update_conversation_token_counts
    conversation.increment!(:total_input_tokens, input_tokens || 0)
    conversation.increment!(:total_output_tokens, output_tokens || 0)
  end
end
