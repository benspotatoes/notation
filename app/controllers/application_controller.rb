class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_user_signed_in
    unless user_signed_in?
      flash[:error] = 'You must be signed in to do that.'
      redirect_to new_user_session_path
      return
    end
  end

  # Overwriting the Devise sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def load_all_entries
    if session[:visible_entries] == 'archived'
      @entries = current_user.entries.where(archived: true).order(updated_at: :desc)
    else
      @entries = current_user.entries.where.not(archived: true).order(updated_at: :desc)
    end
  end
end
