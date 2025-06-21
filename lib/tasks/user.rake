namespace :user do
  desc "Reset the daily API cost for all users to zero"
  task reset_daily_cost: :environment do
    puts "Resetting daily cost for all users..."
    User.update_all(current_daily_cost: 0.0)
    puts "Daily cost reset complete."
  end
end
