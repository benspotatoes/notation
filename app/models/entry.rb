class Entry < ActiveRecord::Base
  belongs_to :user

  TRUNCATED_LENGTH = 100

  def markdown_preview
    RENDERER.render(body).html_safe
  end

  def truncated_body
    body[0..TRUNCATED_LENGTH]
  end

  def archive
    update_attribute(:archived, true)
  end
end
