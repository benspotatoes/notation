class ProfileController < ApplicationController
  before_action :require_user_signed_in
  before_action :load_all_entries
  before_action :load_user

  def show
  end

  def edit
  end

  def update
    @current_password = params[:profile][:current_password]

    if !@user.valid_password?(@current_password)
      flash[:error] = 'Invalid password.'
      redirect_to edit_profile_path(@user.user_id)
      return
    end

    @successfully_updated = []

    if @user.respond_to?(:username) &&
        (!params[:profile][:username].empty? && !@user.username.nil?) &&
        (new_username = params[:profile][:username]) &&
        (@user.username != new_username)
      if try_update_attr(:username, {username: new_username})
        @successfully_updated << :username
      else
        redirect_to edit_profile_path(@user.user_id)
        return
      end
    end

    if !params[:profile][:email].empty? &&
        (new_email = params[:profile][:email]) &&
        (@user.email != new_email)
      if try_update_attr(:email, {email: new_email})
        @successfully_updated << :email
      else
        redirect_to edit_profile_path(@user.user_id)
        return
      end
    end

    if !params[:profile][:password].empty? &&
        (new_password = params[:profile][:password]) &&
        (new_password_confirmation = params[:profile][:password_confirmation])
      password_params = {password: new_password, password_confirmation: new_password_confirmation}
      if try_update_attr(:password, password_params)
        @successfully_updated << :password
      else
        redirect_to edit_profile_path(@user.user_id)
        return
      end
    end

    flash[:success] = "#{@successfully_updated.map(&:to_s).join(', ').capitalize} successfully updated."
    redirect_to show_profile_path(@user.user_id)
  end

  def destroy
    if @user.destroy
      sign_out
      flash[:success] = 'Profile successfully deleted.'
      redirect_to root_path
    else
      flash[:error] = 'Error deleting account.'
      redirect_to edit_profile_path(@user.user_id)
    end
  end

  private

    def try_update_attr(key, value_hash)
      value_hash.merge!(current_password: @current_password)

      if @user.update_with_password(value_hash)
        sign_in @user, bypass: true
      else
        flash[:error] = "Error updating profile #{key.to_s}."
        return false
      end
    end

    def load_user
      @user = User.find_by(user_id: params[:id])
      unless @user == current_user
        flash[:error] = 'You do not have permissions to view that user.'
        redirect_to root_path
      end
    end
end
