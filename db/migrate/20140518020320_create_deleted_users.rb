class CreateDeletedUsers < ActiveRecord::Migration
  def change
    create_table :deleted_users do |t|
      t.integer :primary_id, null: false, unique: true
      t.string :user_id, null: false, unique: true
      t.string :email, null: false
      t.datetime :joined_at, null: false
      t.integer :entry_count, null: false
    end
  end
end
