class CreateWeeklyConsumptions < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_consumptions do |t|
      t.integer :credits, null: false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
