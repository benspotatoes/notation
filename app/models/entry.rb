class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :set_title

  TRUNCATED_BODY_LENGTH = 100
  TRUNCATED_LIST_TITLE_LENGTH = 10
  TRUNCATED_DISP_TITLE_LENGTH = 25
  ENTRY_TITLE_TEMPLATE = 'Note # '

  def markdown_preview
    RENDERER.render(body).html_safe
  end

  def truncated_body
    body[0..TRUNCATED_BODY_LENGTH]
  end

  def archive
    update_attribute(:archived, true)
  end

  def set_title
    if title.nil? || title.empty?
      num_user_entries = Entry.where(:user_id => user_id).count
      self.title = ENTRY_TITLE_TEMPLATE + "#{num_user_entries + 1}"
    end
  end

  def list_title
    if title.length < TRUNCATED_LIST_TITLE_LENGTH
      title
    else
      title[0..TRUNCATED_LIST_TITLE_LENGTH-3].strip + '...'
    end
  end

  def disp_title
    if title.length < TRUNCATED_DISP_TITLE_LENGTH
      title
    else
      title[0..TRUNCATED_DISP_TITLE_LENGTH-3].strip + '...'
    end
  end
end
