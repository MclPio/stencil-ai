class Conversation < ApplicationRecord
  belongs_to :project

  has_many :messages, dependent: :destroy

  def total_tokens
    total_input_tokens + total_output_tokens
  end

  # HOW TO SET TOKEN LIMITS MAYBE MOVE THIS TO PROJECTS LATER OR USER ACCOUNT...
  # def token_limit_reached?(limit)
  #   total_tokens >= limit
  # end

  def user_assistant_messages
    messages.filter { |message| message.role != "system" }
  end

  def formatted_messages
    messages
      .select(:role, :content)
      .order(:created_at)
      .pluck(:role, :content)
      .map { |role, content| { role: role, content: content } }
  end
end
