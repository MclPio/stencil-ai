class CreateArtifacts < ActiveRecord::Migration[8.0]
  def change
    create_table :artifacts do |t|
      t.text :content
      t.references :project, null: false, foreign_key: true
      t.references :favorite_artifact_stencil, null: false, foreign_key: true
      t.timestamps
    end
  end
end

