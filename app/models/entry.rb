class Entry < ActiveRecord::Base
  belongs_to :user

  def preview
    RENDERER.render(body)
  end
end
