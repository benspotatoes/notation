class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :set_title
  before_save :set_entry_id
  before_save :sanitize_tags
  before_save :encrypt_data

  ENTRY_ID_LENGTH = 5
  TRUNCATED_BODY_LENGTH = 100
  TRUNCATED_LIST_TITLE_LENGTH = 10
  TRUNCATED_DISP_TITLE_LENGTH = 25
  ENTRY_TITLE_TEMPLATE = 'Note # '

  CRYPT =
    if Rails.env.production?
      ActiveSupport::MessageEncryptor.new(
        ActiveSupport::KeyGenerator.new(
          ENV['ENCRYPTOR_PASSWORD']).generate_key(
          ENV['ENCRYPTOR_SALT']))
    else
      ActiveSupport::MessageEncryptor.new(
        ActiveSupport::KeyGenerator.new(
          'X'*32).generate_key(
          'X'*32))
    end

  SPECIAL_TAGS = ['todo', 'read-later']

  def decrypted_title
    CRYPT.decrypt_and_verify(title).to_s
  end

  def decrypted_body
    CRYPT.decrypt_and_verify(body).to_s
  end

  def decrypted_tags
    CRYPT.decrypt_and_verify(tags).to_s
  end

  def encrypt_data(override = false)
    self.title = CRYPT.encrypt_and_sign(title) if title_changed? || override
    self.body = CRYPT.encrypt_and_sign(body) if body_changed? || override
    self.tags = CRYPT.encrypt_and_sign(tags) if tags_changed? || override
  end

  def new_title?(check)
    check != CRYPT.decrypt_and_verify(title)
  end

  def new_body?(check)
    check != CRYPT.decrypt_and_verify(body)
  end

  def new_tags?(check)
    check != CRYPT.decrypt_and_verify(tags)
  end

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
      RENDERER.render_with_checkboxes(decrypted_body).html_safe
    elsif with_checkboxes.nil?
      # Render with checkbox only if tags include 'todo'
      if tag_match?('todo')
        RENDERER.render_with_checkboxes(decrypted_body).html_safe
      else
        RENDERER.render(decrypted_body).html_safe
      end
    else
      # Explicitly do not render with checkboxes
      RENDERER.render(decrypted_body).html_safe
    end
  end

  def truncated_body
    decrypted_body[0..TRUNCATED_BODY_LENGTH]
  end

  def archive
    update_attribute(:archived, true)
  end

  def unarchive
    update_attribute(:archived, false)
  end

  def set_title
    if title.nil? || title.empty?
      num_user_entries = Entry.where(user_id: user_id).count
      self.title = ENTRY_TITLE_TEMPLATE + "#{num_user_entries + 1}"
    end
  end

  def list_title
    if decrypted_title.length < TRUNCATED_LIST_TITLE_LENGTH
      decrypted_title
    else
      decrypted_title[0..TRUNCATED_LIST_TITLE_LENGTH-3].strip + '...'
    end
  end

  def disp_title
    to_display =
      if decrypted_title.length < TRUNCATED_DISP_TITLE_LENGTH
        decrypted_title
      else
        decrypted_title[0..TRUNCATED_DISP_TITLE_LENGTH-3].strip + '...'
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

    decrypted_tags.split(', ').each_with_index do |tag, index|
      yield tag.strip, index
    end
  end

  def tag_count
    decrypted_tags.split(', ').count
  end

  def tag_match?(tag = '')
    decrypted_tags.downcase.include?(tag)
  end

  def has_tags?
    decrypted_tags.length > 0
  end
end

module Redcarpet
  class Markdown
    include ActionView::Helpers

    # https://github.com/vmg/redcarpet/issues/323
    # Render text with checkboxes, not built in to default Redcarpet module
    def render_with_checkboxes(text, parser_options = {strict_parse_checklist: true}, data_options = {})
      # Perform base rendering to convert lists appropriately
      base_render = render(text)

      # Convert all checkbox syntax to checkbox inputs
      checkbox_regex  = /\[(x|\s)\]/
      checkbox_match = false
      checkbox_render = base_render.gsub(checkbox_regex).with_index do |match, idx|
        checkbox_match = true
        checked = match =~ /x/ ? true : false
        check_box_tag "todo_#{idx}", '', checked, data: data_options, disabled: true
      end

      # Do some "repairing" if we know we've added checkbox inputs
      if checkbox_match
        lines = []
        each_line = checkbox_render.split("\n")
        each_line.each_with_index do |line, idx|

          # Append appropriate class to unordered lists that contain checkboxes
          if idx + 2 < each_line.count &&
                line.match(/<ul>/) && each_line[idx + 1].match(/<li>/) &&
              ( each_line[idx + 1].match(/type="checkbox"/) ||
                each_line[idx + 2].match(/type="checkbox"/))
            line_to_add = line.gsub('<ul>', "<ul class='todo'>")
          elsif line.match(/<p><input id="todo_(\d+)"/) && parser_options[:strict_parse_checklist]
            # There are cases where a checkbox is inadvertently added due to poor syntax,
            # so we should take out the checkbox and remove faulty syntax
            input = check_box_tag "todo_#{$1}", '', false, data: data_options
            line_to_add = "#{line.gsub(input, '')}"
          else line_to_add = line
            line_to_add = line
          end

          lines << line_to_add
        end
        return final_render = lines.join("\n")
      else
        return checkbox_render
      end
    end
  end
end
