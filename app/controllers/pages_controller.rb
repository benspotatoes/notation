class PagesController < ApplicationController
  def root
    if user_signed_in?
      puts "==#{session[:entry_tag] || Entry::NOTE_ENTRY_TAG}"
      redirect_to all_entries_path(session[:entry_tag] || Entry::NOTE_ENTRY_TAG)
    else
      redirect_to new_user_session_path
    end
  end
end
