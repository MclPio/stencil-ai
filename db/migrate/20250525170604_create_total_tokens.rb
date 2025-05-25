class CreateTotalTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :total_tokens do |t|
      t.integer :total, default: 0
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
