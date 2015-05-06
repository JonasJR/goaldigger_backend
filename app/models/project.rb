class Project < ActiveRecord::Base
  belongs_to :user
  has_many :milestones, dependent: :destroy

  #validates :name, presence: true, length: { maximum: 30 }
end
