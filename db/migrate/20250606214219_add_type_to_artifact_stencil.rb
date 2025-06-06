class AddTypeToArtifactStencil < ActiveRecord::Migration[8.0]
  def change
    add_column :artifact_stencils, :category, :int, default: 0, null: false
  end
end
