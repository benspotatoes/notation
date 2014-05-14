class SetDefaultEntryTags < ActiveRecord::Migration
  def change
    change_column :entries, :tags, :string, default: ''
  end
end
