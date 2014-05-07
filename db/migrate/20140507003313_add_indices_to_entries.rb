class AddIndicesToEntries < ActiveRecord::Migration
  def change
    change_column :entries, :entry_id, :string, null: false
    add_index :entries, [:user_id, :entry_id], unique: true
  end
end
