class AddUniqueIndexToFavoriteArtifactStencils < ActiveRecord::Migration[8.0]
  def change
    add_index :favorite_artifact_stencils, [ :user_id, :artifact_stencil_id ], unique: true
  end
end
