class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :set_title
  before_save :set_entry_id
  before_save :sanitize_tags

  ENTRY_ID_LENGTH = 5
  TRUNCATED_BODY_LENGTH = 100
  TRUNCATED_LIST_TITLE_LENGTH = 10
  TRUNCATED_DISP_TITLE_LENGTH = 25
  ENTRY_TITLE_TEMPLATE = 'Note # '

  def set_entry_id
    if entry_id.nil?
      self.entry_id = SecureRandom.hex(ENTRY_ID_LENGTH)
    end
  end

  def public_id
    entry_id
  end

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
      num_user_entries = Entry.where(user_id: user_id).count
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
    to_display =
      if title.length < TRUNCATED_DISP_TITLE_LENGTH
        title
      else
        title[0..TRUNCATED_DISP_TITLE_LENGTH-3].strip + '...'
      end
    if archived?
      "(#{to_display})"
    else
      to_display
    end
  end

  def sanitize_tags
    if tags
      self.tags = tags.split(',').map(&:strip).join(', ') if tags
    end
  end

  def each_tag
    return tags unless block_given?
    tags.split(', ').each_with_index do |tag, index|
      yield tag.strip, index
    end
  end

  def tag_count
    tags.split(', ').count
  end

  def tag_match?(tag = '')
    tags.include?(tag)
  end

  def has_tags?
    tags.length > 0
  end
end
