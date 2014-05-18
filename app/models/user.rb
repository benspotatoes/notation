class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :entries

  before_save :set_user_id

  USER_ID_LENGTH = 10

  def set_user_id
    if user_id.nil?
      self.user_id = SecureRandom.hex(USER_ID_LENGTH)
    end
  end

  def destroy
    if DeletedUser.create_from_user(self)
      super
    else
      false
    end
  end
end
