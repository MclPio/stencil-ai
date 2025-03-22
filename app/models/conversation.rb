class Conversation < ApplicationRecord
  belongs_to :project

  has_many :messages, dependent: :destroy

  def total_tokens
    total_input_tokens + total_output_tokens
  end

  # HOW TO SET TOKEN LIMITS MAYBE MOVE THIS TO PROJECTS LATER OR USER ACCOUNT...
  def token_limit_reached?(limit)
    total_tokens >= limit
  end

  def formatted_messages
    messages.order(:created_at).map do |message|
      { role: message.role, content: message.content }
    end
  end
end
