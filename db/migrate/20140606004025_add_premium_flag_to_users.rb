class AddPremiumFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :premium, :boolean, default: false
  end
end
