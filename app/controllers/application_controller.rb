class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

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
    @entries = current_user.entries.where(entry_type: Entry.entry_types[Entry::ENTRY_TAG_TYPES[session[:entry_tag]]])
    if session[:visible_entries] == 'archived'
      @entries = @entries.where(archived: true)
    else
      @entries = @entries.where.not(archived: true)
    end
    @entries = @entries.order(updated_at: :desc)
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
    end
end
