class DeletedUser < ActiveRecord::Base
  def self.create_from_user(user)
    create!(
      primary_id: user.id,
      user_id: user.user_id,
      email: user.email,
      joined_at: user.created_at,
      entry_count: user.entries.count)
  end
end