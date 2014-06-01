class Entry < ActiveRecord::Base
  enum entry_type: [ :default, :note, :todo, :read_later ]

  belongs_to :user

  before_save :set_title
  before_save :set_entry_id
  before_save :sanitize_tags
  before_save :set_entry_type
  before_save :encrypt_data

  ENTRY_ID_LENGTH = 5
  TRUNCATED_BODY_LENGTH = 100
  TRUNCATED_LIST_TITLE_LENGTH = 10
  TRUNCATED_DISP_TITLE_LENGTH = 25
  ENTRY_TITLE_TEMPLATE = 'Note # '

  NOTE_ENTRY_TAG = 'now'
  TODO_ENTRY_TAG = 'then'
  READ_ENTRY_TAG = 'later'
  ENTRY_TAG_TYPES = {
    NOTE_ENTRY_TAG => 'note',
    TODO_ENTRY_TAG => 'todo',
    READ_ENTRY_TAG => 'read_later'
  }

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

  def set_entry_type
    if tags_changed? || default?
      if !tags.empty?
        Entry.entry_types.each do |type, int|
          if tag_match?(type, true)
            self.entry_type = type
            return
          end
        end
      end
      self.entry_type = ENTRY_TAG_TYPES[NOTE_ENTRY_TAG]
    end
  end

  def decrypted_title
    # Title is guaranteed to exist with :set_title
    CRYPT.decrypt_and_verify(title).to_s
  end

  def decrypted_body
    # Body does not always exist, can be nil
    body.empty? ? '' : CRYPT.decrypt_and_verify(body).to_s
  end

  def decrypted_tags
    # Tags default to an empty string
    tags.empty? ? '' : CRYPT.decrypt_and_verify(tags).to_s
  end

  def encrypt_data(override = false)
    self.title = CRYPT.encrypt_and_sign(title) if title_changed? || override
    self.body = CRYPT.encrypt_and_sign(body) if body_changed? || override
    self.tags = CRYPT.encrypt_and_sign(tags) if tags_changed? || override
  end

  def set_entry_id
    if entry_id.nil?
      random_id = generate_entry_id
      while !self.class.find_by(entry_id: random_id, user_id: user_id).nil?
        # In the rare case we do run into a duplicate, get another one
        random_id = generate_entry_id
      end
      self.entry_id = random_id
    end
  end

  def generate_entry_id
    SecureRandom.hex(ENTRY_ID_LENGTH)
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
      self.tags = tags.split(',').map(&:strip).join(', ')
    end
  end

  def each_tag(callback = false)
    return decrypted_tags unless block_given?

    if callback
      # For a callback, tags have not been encrypted yet
      tags.split(', ').each_with_index do |tag, index|
        yield tag.strip, index
      end
    else
      decrypted_tags.split(', ').each_with_index do |tag, index|
        yield tag.strip, index
      end
    end
  end

  def tag_count
    decrypted_tags.split(', ').count
  end

  def tag_match?(target = '', callback = false)
    each_tag(callback) do |tag|
      if tag.downcase == target
        return true
      end
    end

    return false
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
