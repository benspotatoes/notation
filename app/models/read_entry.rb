class ReadEntry < ActiveRecord::Base
  attr_accessor :user_id, :body, :tags, :title

  belongs_to :entry, foreign_key: :entry_primary_id, dependent: :destroy

  before_save :set_details

  def set_details
    page = AGENT.get(url)
    unless title
      self.title = page.title
    end
    self.host = page.uri.host

    entry = create_entry
    self.entry_primary_id = entry.id
  end

  def create_entry
    e = Entry.new(user_id: user_id, title: title, entry_type: 3)

    if body
      e.body = body
    end

    if tags
      e.tags = tags
    end

    e.save!
    e
  end
end
