class CreateSpecs < ActiveRecord::Migration[8.0]
  def change
    create_table :specs do |t|
      t.text :content
      t.text :user_flow
      t.text :model_erd
      t.text :roadmap_flow
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
