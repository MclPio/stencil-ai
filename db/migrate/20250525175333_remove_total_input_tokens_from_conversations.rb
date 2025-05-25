class RemoveTotalInputTokensFromConversations < ActiveRecord::Migration[8.0]
  def change
    remove_column :conversations, :total_input_tokens, :integer
  end
end
