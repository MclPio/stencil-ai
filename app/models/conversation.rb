class Conversation < ApplicationRecord
  belongs_to :project

  has_many :messages, dependent: :destroy
  has_one :total_token, dependent: :destroy
  after_create :create_total_token

  TOKEN_LIMIT = 96_000

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
