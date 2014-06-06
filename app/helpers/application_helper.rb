module ApplicationHelper
  def for_read_entry?
    session[:entry_tag] == Entry::READ_ENTRY_TAG
  end

  def can_upload_file?
    current_user.premium? || !current_user.max_uploads?
  end
end
