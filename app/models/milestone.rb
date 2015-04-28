class Milestone < ActiveRecord::Base
  belongs_to :project
  has_many :items

  validates :name, presence: true, length: { maximum: 30 }
end
