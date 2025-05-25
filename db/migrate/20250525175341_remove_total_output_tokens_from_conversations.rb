class RemoveTotalOutputTokensFromConversations < ActiveRecord::Migration[8.0]
  def change
    remove_column :conversations, :total_output_tokens, :integer
  end
end
