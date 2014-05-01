class Entry < ActiveRecord::Base
  belongs_to :user

  TRUNCATED_BODY_LENGTH = 100
  TRUNCATED_LIST_TITLE_LENGTH = 10
  TRUNCATED_DISP_TITLE_LENGTH = 25

  def markdown_preview
    RENDERER.render(body).html_safe
  end

  def truncated_body
    body[0..TRUNCATED_BODY_LENGTH]
  end

  def archive
    update_attribute(:archived, true)
  end

  def list_title
    if title.length < TRUNCATED_LIST_TITLE_LENGTH
      title
    else
      title[0..TRUNCATED_LIST_TITLE_LENGTH-3] + '...'
    end
  end

  def disp_title
    if title.length < TRUNCATED_DISP_TITLE_LENGTH
      title
    else
      title[0..TRUNCATED_DISP_TITLE_LENGTH-3] + '...'
    end
  end
end
