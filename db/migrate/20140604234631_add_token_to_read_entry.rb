class AddTokenToReadEntry < ActiveRecord::Migration
  def change
    add_column :read_entries, :token, :string
  end
end
