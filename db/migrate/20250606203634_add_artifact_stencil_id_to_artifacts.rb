class AddArtifactStencilIdToArtifacts < ActiveRecord::Migration[8.0]
  def change
    add_column :artifacts, :artifact_stencil_id, :bigint
    add_foreign_key :artifacts, :artifact_stencils
  end
end
