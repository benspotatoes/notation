class RemoveReadEntryRequirements < ActiveRecord::Migration
  def self.up
    remove_column :read_entries, :url, :string
    remove_column :read_entries, :host, :string
    add_column :read_entries, :url, :string
    add_column :read_entries, :host, :string
  end

  def self.down
    change_column :read_entries, :url, :string, null: false
    change_column :read_entries, :host, :string, null: false
  end
end
