class EntriesController < ApplicationController
  before_action :set_entry_tag
  before_action :require_user_signed_in
  before_action :load_entry, only: [:show, :edit, :update, :archive]

  def index
    @entry_form_path = create_entry_path
    @entry_form_request = :post
    @new_read_entry = true

    session[:entry_list_title] = 'Active entries'
    session.delete(:visible_entries)
    session.delete(:by_tag)

    load_all_entries
  end

  def by_tag
    tag = params[:tag]
    session[:by_tag] = tag
    session[:entry_list_title] = "Tag: '#{tag}'"

    load_all_entries
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
    case session[:entry_tag]
    when Entry::READ_ENTRY_TAG
      @entry = ReadEntry.new(entry_params)
    else
      @entry = Entry.new(entry_params)
      @entry.entry_type = Entry::ENTRY_TAG_TYPES[session[:entry_tag]]
    end
    @entry.user_id = current_user.id

    if @entry.save
      flash[:success] = 'Entry successfully saved.'

      # When creating a new entry, always show active entries
      session[:entry_list_title] = 'Active entries'
      session.delete(:by_tag)

      load_all_entries

      redirect_to show_entry_path(@entry.public_id)
    else
      error_msg = "Error saving entry."
      @entry.errors.messages.each do |what, failed|
        error_msg += "<br/>"
        error_msg += "#{what}: #{failed.join(", ")}"
      end
      error_msg += "."
      flash[:error] = error_msg
      redirect_to all_entries_path(session[:entry_tag])
    end
  end

  def show
    @display_entry = @entry

    change_entry_tag
    load_all_entries
    filter_entries_by_tag
  end

  def edit
    load_all_entries

    @display_entry = @entry
    @entry_form_path = update_entry_path
    @entry_form_request = :put
  end

  def update
    load_all_entries

    case session[:entry_tag]
    when Entry::READ_ENTRY_TAG
      @entry = @entry.read_entry
    end

    if @entry.update_attributes(entry_params)
      flash[:success] = 'Entry successfully updated.'
    else
      error_msg = "Error updating entry."
      @entry.errors.messages.each do |what, failed|
        error_msg += "<br/>"
        error_msg += "#{what}: #{failed.join(", ")}"
      end
      error_msg += "."
      flash[:error] = error_msg
    end

    redirect_to show_entry_path(@entry.public_id)
  end

  def archive
    load_all_entries

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
        redirect_to all_entries_path(session[:entry_tag])
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
        redirect_to all_entries_path(session[:entry_tag])
        return
      end
    end

    def entry_params
      default_params = [:title, :body, :tags]
      allowed_params = []

      case session[:entry_tag]
      when Entry::READ_ENTRY_TAG
        allowed_params += [:url, :attachment]
      end

      params.require(:entry).permit(default_params + allowed_params)
    end

    def filter_entries_by_tag
      if tag = session[:by_tag]
        @entries = @entries.select { |entry| entry.tag_match?(tag.downcase) }
      end
    end

    def change_entry_tag
      if @display_entry.note?
        session[:entry_tag] = Entry::NOTE_ENTRY_TAG
      elsif @display_entry.todo?
        session[:entry_tag] = Entry::TODO_ENTRY_TAG
      elsif @display_entry.read_later?
        session[:entry_tag] = Entry::READ_ENTRY_TAG
      end
    end

    def set_entry_tag
      if params[:entry_tag]
        session[:entry_tag] = params[:entry_tag]
      else
        unless session[:entry_tag]
          session[:entry_tag] = Entry::NOTE_ENTRY_TAG
        end
      end
    end
end
