class User < ActiveRecord::Base
  has_many :projects, dependent: :destroy
  has_many :items
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  has_many :collaborations, dependent: :destroy
  has_many :shared_projects, through: :collaborations, source: :project

  validates :name, presence: true, length: { maximum: 50 }
  validates :password, presence: true, length: { minimum: 6, maximum: 255 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 50 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true


  has_secure_password

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def friend?(friend)
    friends.include?
  end
end
