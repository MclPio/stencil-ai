class CreateArtifacts < ActiveRecord::Migration[8.0]
  def change
    create_table :artifacts do |t|
      t.string :name, null: false
      t.text :prompt, null: false
      t.text :content
      t.boolean :published, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :artifacts, :published
  end
end
