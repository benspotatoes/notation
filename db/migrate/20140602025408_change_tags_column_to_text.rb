class ChangeTagsColumnToText < ActiveRecord::Migration
  def change
    change_column_default(:entries, :tags, nil)
    change_column :entries, :tags, :text
  end
end
