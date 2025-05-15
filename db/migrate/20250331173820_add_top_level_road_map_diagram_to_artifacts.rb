class AddTopLevelRoadMapDiagramToArtifacts < ActiveRecord::Migration[8.0]
  def change
    add_column :artifacts, :top_level_roadmap_diagram, :text
  end
end
