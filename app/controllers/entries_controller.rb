class EntriesController < ApplicationController
  before_action :require_user_signed_in
  before_action :load_entry, only: [:show, :edit, :update, :destroy]

  def index
    @entries = current_user.entries
  end

  def new
  end

  def create
    @entry = Entry.new(entry_params)
    @entry.user = current_user
    if @entry.save
      flash[:success] = 'Entry successfully saved.'
      redirect_to show_entry_path(@entry.id)
    else
      flash[:error] = 'Error saving entry.'
      redirect_to new_entry_path
    end
  end

  def show
  end

  def edit
  end

  def update
    if @entry.update_attributes(entry_params)
      flash[:success] = 'Entry successfully updated.'
    else
      flash[:error] = 'Error updating entry.'
    end
    redirect_to show_entry_path(@entry.id)
  end

  def destroy
    if @entry.destroy
      flash[:success] = 'Entry successfully deleted.'
      redirect_to all_entries_path
    else
      flash[:error] = 'Error deleting entry.'
      redirect_to show_entry_path(@entry.id)
    end
  end

  private
    def load_entry
      @entry = Entry.find(params[:id])
    end

    def entry_params
      params.require(:entry).permit(:body, :tags)
    end
end
