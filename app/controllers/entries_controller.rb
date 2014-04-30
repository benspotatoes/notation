class EntriesController < ApplicationController
  before_action :require_user_signed_in
  before_action :load_all_entries
  before_action :load_entry, only: [:show, :edit, :update, :archive]

  def index
    @entry_form_path = create_entry_path
    @entry_form_request = :post
  end

  def create
    @entry = Entry.new(entry_params)
    @entry.user = current_user
    if @entry.save
      flash[:success] = 'Entry successfully saved.'
      redirect_to show_entry_path(@entry.id)
    else
      flash[:error] = 'Error saving entry.'
      redirect_to all_entries_path
    end
  end

  def show
    @display_entry = @entry
  end

  def edit
    @entry_form_path = update_entry_path
    @entry_form_request = :put
  end

  def update
    if @entry.update_attributes(entry_params)
      flash[:success] = 'Entry successfully updated.'
    else
      flash[:error] = 'Error updating entry.'
    end
    redirect_to show_entry_path(@entry.id)
  end

  def archive
    if @entry.archive
      flash[:success] = 'Entry successfully archived.'
      redirect_to all_entries_path
    else
      flash[:error] = 'Error archiving entry.'
      redirect_to show_entry_path(@entry.id)
    end
  end

  private
    def load_entry
      @entry = Entry.find_by_id(params[:id])
      if @entry.nil? || (@entry.user != current_user)
        flash[:error] = 'You do not have permission to view that entry.'
        redirect_to all_entries_path
        return
      end
    end

    def load_all_entries
      @entries = current_user.entries.where.not(archived: true)
    end

    def entry_params
      params.require(:entry).permit(:title, :body, :tags)
    end
end
