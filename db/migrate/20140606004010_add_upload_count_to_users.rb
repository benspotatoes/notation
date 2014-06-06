class AddUploadCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :upload_count, :integer, default: 0
  end
end
