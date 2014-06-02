module ApplicationHelper
  def for_read_entry?
    session[:entry_tag] == Entry::READ_ENTRY_TAG
  end
end
