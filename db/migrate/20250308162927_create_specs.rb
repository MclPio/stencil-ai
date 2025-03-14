class CreateSpecs < ActiveRecord::Migration[8.0]
  def change
    create_table :specs do |t|
      t.text :content
      t.text :value_flow
      t.text :models
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
