class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :user_id, null: false
      t.text :body
      t.boolean :archived, default: false
      t.string :tags

      t.timestamps
    end

    add_index :entries, [:user_id], unique: false
  end
end
