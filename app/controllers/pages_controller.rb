class PagesController < ApplicationController
  def ping
    head :ok
  end

  def root
    if user_signed_in?
      redirect_to all_entries_path(session[:entry_tag] || Entry::NOTE_ENTRY_TAG)
    else
      redirect_to new_user_session_path
    end
  end
end
