class AddTopLevelRoadMapDiagramToSpecs < ActiveRecord::Migration[8.0]
  def change
    add_column :specs, :top_level_roadmap_diagram, :text
  end
end
