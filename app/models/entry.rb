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

  def markdown_preview(with_checkboxes = nil)
    if with_checkboxes
      # Explicitly render with checkboxes
      RENDERER.render_with_checkboxes(body).html_safe
    elsif with_checkboxes.nil?
      # Render with checkbox only if tags include 'todo'
      if tag_match?('todo')
        RENDERER.render_with_checkboxes(body).html_safe
      else
        RENDERER.render(body).html_safe
      end
    else
      # Explicitly do not render with checkboxes
      RENDERER.render(body).html_safe
    end
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
    tags.downcase.include?(tag)
  end

  def has_tags?
    tags.length > 0
  end
end

module Redcarpet
  class Markdown
    include ActionView::Helpers

    # https://github.com/vmg/redcarpet/issues/323
    # Render text with checkboxes, not built in to default Redcarpet module
    def render_with_checkboxes(text, data_options = {})
      text = render(text)
      checkbox_regex  = /\[(x|\s)\]/
      checkbox_match = false
      text = text.gsub(checkbox_regex).with_index do |match, idx|
        checkbox_match = true
        checked = match =~ /x/ ? true : false
        check_box_tag "todo_#{idx}", '', false, data: data_options
      end
      if checkbox_match
        lines = []
        each_line = text.split("\n")
        each_line.each_with_index do |line, idx|
          next if idx + 2 > each_line.count
          if line.match(/<ul>/) && each_line[idx + 1].match(/<li>/) &&
              ( each_line[idx + 1].match(/type="checkbox"/) ||
                each_line[idx + 2].match(/type="checkbox"/))
            lines << line.gsub('<ul>', "<ul class='todo'>")
          else
            lines << line
          end
        end
        text = lines.join("\n")
      end
      render(text)
    end
  end
end
