class AddValueFlowDiagramToSpec < ActiveRecord::Migration[8.0]
  def change
    add_column :specs, :value_flow_diagram, :text
  end
end
