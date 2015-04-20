class User < ActiveRecord::Base
  has_many :projects

  validates :password, presence: true, length: { minimum: 6 }
  validates :email, presence: true, length: { maximum: 50 }

  has_secure_password
end
