class CreateArtifacts < ActiveRecord::Migration[8.0]
  def change
    create_table :artifacts do |t|
      t.string :name, null: false
      t.text :prompt, null: false
      t.text :content
      t.boolean :public, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
