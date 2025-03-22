class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :title
      t.integer :total_input_tokens, default: 0
      t.integer :total_output_tokens, default: 0
      t.references :projects, null: false, foreign_key: true

      t.timestamps
    end
  end
end
