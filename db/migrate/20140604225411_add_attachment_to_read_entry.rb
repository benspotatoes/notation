class AddAttachmentToReadEntry < ActiveRecord::Migration
  def change
    add_attachment :read_entries, :attachment
  end
end
