class AddTypeToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :entry_type, :integer, default: 0
  end
end
