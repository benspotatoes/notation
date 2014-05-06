class AddEntryIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :entry_id, :string
  end
end
