class CreateInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :invites do |t|
      t.string :invite_code, null: false
      t.integer :created_by_id, null: false
      t.integer :used_by_id
      t.datetime :expires_at

      t.timestamps
    end
    add_index :invites, :invite_code, unique: true
    add_index :invites, :created_by_id
    add_index :invites, :used_by_id
  end
end
