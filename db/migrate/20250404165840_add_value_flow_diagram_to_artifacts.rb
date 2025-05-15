class AddValueFlowDiagramToArtifacts < ActiveRecord::Migration[8.0]
  def change
    add_column :artifacts, :value_flow_diagram, :text
  end
end
