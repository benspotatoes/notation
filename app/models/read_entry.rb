class ReadEntry < Entry
  before_save :verify_tags

  def verify_tags
    target = ENTRY_TAG_TYPES[READ_ENTRY_TAG]

    unless tag_match?(target)
      if decrypted_tags.empty?
        update_attribute(:tags, target)
      else
        update_attribute(:tags, decrypted_tags + "#{target}")
      end
    end
  end
end
