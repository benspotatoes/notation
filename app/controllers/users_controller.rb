class UsersController < ApplicationController
  before_action :load_user

  def show
  end

  def edit
  end

  def update
    user_params = params[:user]
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile successfully updated.'
      redirect_to edit_user_path(@user.user_id)
    else
      flash[:error] = 'Error updating profile.'
      redirect_to edit_user_path(@user.user_id)
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = 'Profile successfully deleted.'
      sign_out
      redirect_to root_path
    else
      flash[:error] = 'Error deleting account.'
      redirect_to edit_user_path(@user.user_id)
    end
  end

  private

    def load_user
      @user = Entry.find_by(user_id: params[:id])
      unless @user == current_user
        flash[:error] = 'You do not have permissions to view that user.'
        redirect_to root_path
      end
    end
end
