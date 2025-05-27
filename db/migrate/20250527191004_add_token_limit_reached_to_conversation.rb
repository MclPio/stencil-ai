class AddTokenLimitReachedToConversation < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :reached_token_limit, :boolean, default: false
  end
end
