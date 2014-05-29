class SetDefaultEntryBody < ActiveRecord::Migration
  def change
    change_column :entries, :body, :text, default: ''
  end
end
