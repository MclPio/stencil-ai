class RemoveIdeaFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :idea, :string
  end
end
