class User < ActiveRecord::Base
  has_many :projects
  has_many :items
  has_many :friendships
  has_many :friends, through: :friendships

  has_many :collaborations
  has_many :shared_projects, through: :collaborations, source: :project

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :password, presence: true, length: { minimum: 6, maximum: 255 }

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
