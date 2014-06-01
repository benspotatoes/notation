class EntriesController < ApplicationController
  before_action :require_user_signed_in
  before_action :load_all_entries
  before_action :load_entry, only: [:show, :edit, :update, :archive]

  def index
    @entry_form_path = create_entry_path
    @entry_form_request = :post

    session[:entry_list_title] = 'Active entries'
    session.delete(:by_tag)

    if session.delete(:visible_entries)
      # Reload all entries to get 'active' ones
      load_all_entries
    end
  end

  def by_tag
    tag = params[:tag]
    session[:by_tag] = tag
    session[:entry_list_title] = "Tag: '#{tag}'"

    filter_entries_by_tag

    if @display_entry = @entry = @entries.first
      render 'show'
    else
      @entry_form_path = create_entry_path
      @entry_form_request = :post
      render 'index'
    end
  end

  def create
    @entry = Entry.new(entry_params)
    @entry.user = current_user
    if @entry.save
      flash[:success] = 'Entry successfully saved.'

      # When creating a new entry, always show active entries
      session[:entry_list_title] = 'Active entries'
      session.delete(:by_tag)

      if session.delete(:visible_entries)
        # Reload all entries to get 'active' ones
        load_all_entries
      end

      redirect_to show_entry_path(@entry.public_id)
    else
      flash[:error] = 'Error saving entry.'
      redirect_to all_entries_path
    end
  end

  def show
    @display_entry = @entry
    filter_entries_by_tag
  end

  def edit
    @display_entry = @entry
    @entry_form_path = update_entry_path
    @entry_form_request = :put
  end

  def update
    if @entry.new_title?(entry_params[:title])
      @entry.title = entry_params[:title]
    end
    if @entry.new_body?(entry_params[:body])
      @entry.body = entry_params[:body]
    end
    if @entry.new_tags?(entry_params[:tags])
      @entry.tags = entry_params[:tags]
    end

    if @entry.save
      flash[:success] = 'Entry successfully updated.'
    else
      flash[:error] = 'Error updating entry.'
    end
    redirect_to show_entry_path(@entry.public_id)
  end

  def archive
    if @entry.archived
      # Unarchive an entry
      if @entry.unarchive
        flash[:success] = 'Entry successfully unarchived.'
      else
        flash[:error] = 'Error unarchiving entry.'
      end
        redirect_to show_entry_path(@entry.public_id)
    else
      # Archive an entry
      if @entry.archive
        flash[:success] = 'Entry successfully archived.'
        redirect_to all_entries_path
      else
        flash[:error] = 'Error archiving entry.'
        redirect_to show_entry_path(@entry.public_id)
      end
    end
  end

  def archived_entries
    session[:entry_list_title] = 'Archived entries'
    session[:visible_entries] = 'archived'
    session.delete(:by_tag)
    load_all_entries

    if @display_entry = @entry = @entries.first
      render 'show'
    else
      @entry_form_path = create_entry_path
      @entry_form_request = :post
      render 'index'
    end
  end

  private
    def load_entry
      @entry = Entry.find_by(entry_id: params[:id], user_id: current_user.id)
      if @entry.nil? || (@entry.user != current_user)
        flash[:error] = 'You do not have permission to view that entry.'
        redirect_to all_entries_path
        return
      end
    end

    def entry_params
      params.require(:entry).permit(:title, :body, :tags)
    end

    def filter_entries_by_tag
      if tag = session[:by_tag]
        @entries = @entries.select { |entry| entry.tag_match?(tag.downcase) }
      end
    end
end
