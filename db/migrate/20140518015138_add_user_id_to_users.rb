class AddUserIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :user_id, :string
    User.where(user_id: nil).each do |user|
      user.set_user_id
      user.save!
    end
    change_column :users, :user_id, :string, null: false
    add_index :users, [:user_id], unique: true
  end

  def self.down
    remove_index :users, [:id, :user_id]
    remove_column :users, :user_id
  end
end
