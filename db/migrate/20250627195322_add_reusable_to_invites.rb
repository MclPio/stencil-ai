class AddReusableToInvites < ActiveRecord::Migration[8.0]
  def change
    add_column :invites, :reusable, :boolean, default: false, null: false
  end
end
