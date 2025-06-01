class CreateArtifactStencils < ActiveRecord::Migration[8.0]
  def change
    create_table :artifact_stencils do |t|
      t.string :name, null: false
      t.text :prompt, null: false
      t.string :description, null: false
      t.boolean :published, null: false, default: false
      t.references :user, null: false, foreign_key: true
      t.integer :usage_count, default: 0

      t.timestamps
    end
  end
end
