class PagesController < ApplicationController
  def root
    if user_signed_in?
      redirect_to all_note_entries_path
    else
      redirect_to new_user_session_path
    end
  end
end
