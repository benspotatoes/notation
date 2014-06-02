class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_entry_type

  rescue_from Exception, :with => :error_response

  def add_entry
    permit_add_params
    set_entry_params

    case @entry_type
    when Entry::ENTRY_TAG_TYPES[Entry::READ_ENTRY_TAG]
      entry = ReadEntry.new(@entry_params)
      head :created if entry.save!
    end
  end

  def remove_entry
    permit_remove_params

    case @entry_type
    when Entry::ENTRY_TAG_TYPES[Entry::READ_ENTRY_TAG]
      entry = Entry.find_by(user_id: params[:user_id], entry_id: params[:entry_id])
      if entry
        case params[:remove_action]
        when 'archive'
          if entry.archive
            head :no_content
          else
            head :internal_server_error
          end
        when 'delete'
          head :not_implemented
        end
      else
        head :not_found
      end
    end
  end

  private
    def error_response(e)
      if Rails.env.development?
        raise e
      else
        render status: :internal_server_error,
               json: {error: e.to_s}
      end
    end

    def permit_add_params
      params.require(:url)
      params.require(:user_id)
      params.require(:entry_type)
      params.permit([:tags, :notes])
    end

    def permit_remove_params
      params.require(:user_id)
      params.require(:entry_id)
      params.require(:entry_type)
      params.require(:remove_action)
    end

    def set_entry_type
      @entry_type = params[:entry_type]
      unless @entry_type.in?(Entry.entry_types.keys)
        render status: :bad_request,
               json: {error: 'Invalid entry_type.'}
        return
      end
    end

    def set_entry_params
      case @entry_type
      when Entry::ENTRY_TAG_TYPES[Entry::READ_ENTRY_TAG]
        @entry_params = {
          user_id: params[:user_id],
          url: params[:url],
          tags: params[:tags] || '',
          body: params[:notes] || ''
        }
      end
    end
end
