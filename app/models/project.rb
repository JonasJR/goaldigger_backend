class Project < ActiveRecord::Base
  belongs_to :user
  has_many :milestones, dependent: :delete_all

  #validates :name, presence: true, length: { maximum: 30 }
end
