class ChangeTagsColumnToText < ActiveRecord::Migration
  def change
    change_column :entries, :tags, :text
  end
end
