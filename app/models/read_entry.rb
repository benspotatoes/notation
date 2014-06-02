class ReadEntry < ActiveRecord::Base
  attr_accessor :user_id, :body, :tags, :title

  belongs_to :entry, foreign_key: :entry_primary_id

  before_save :set_url_details
  before_create :set_entry_details

  def set_url_details
    page = AGENT.get(url)

    if entry.nil?
      self.title = page.title
    else
      entry.update_attribute(:title, page.title)
    end
    self.host = page.uri.host
  end

  def set_entry_details
    entry = Entry.new(user_id: user_id, title: title, entry_type: 3)

    if body
      entry.body = body
    end

    if tags
      entry.tags = tags
    end

    entry.save!
    self.entry_primary_id = entry.id
  end

  def public_id
    entry.public_id
  end
end
