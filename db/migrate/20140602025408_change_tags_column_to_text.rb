class ChangeTagsColumnToText < ActiveRecord::Migration
  def change
    change_column :entries, :tags, :text
    change_column_default(:entries, :tags, nil)
  end
end
