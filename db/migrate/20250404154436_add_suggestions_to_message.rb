class AddSuggestionsToMessage < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :suggestions, :text, array: true, default: []
  end
end
