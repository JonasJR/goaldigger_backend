class Project < ActiveRecord::Base
  belongs_to :user
  has_many :milestones, dependent: :destroy

  has_many :collaborations
  has_many :participants, through: :collaborations, source: :user

  #validates :name, presence: true, length: { maximum: 30 }
end
