class CreateReadEntries < ActiveRecord::Migration
  def change
    create_table :read_entries do |t|
      t.integer :entry_primary_id, null: false
      t.string :url, null: false
      t.string :host, null: false
    end

    add_index :read_entries, [:entry_primary_id], unique: true
  end
end
