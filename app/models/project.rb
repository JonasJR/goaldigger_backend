class Project < ActiveRecord::Base
  belongs_to :user
  has_many :milestones
  has_many :items

  #validates :name, presence: true, length: { maximum: 30 }
end
