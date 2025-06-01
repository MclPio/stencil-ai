class CreateFavoriteArtifactStencils < ActiveRecord::Migration[8.0]
  def change
    create_table :favorite_artifact_stencils do |t|
      t.references :artifact_stencil, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
