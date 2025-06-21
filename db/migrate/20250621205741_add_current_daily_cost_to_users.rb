class AddCurrentDailyCostToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_daily_cost, :decimal, precision: 10, scale: 5, null: false, default: 0.0
  end
end
