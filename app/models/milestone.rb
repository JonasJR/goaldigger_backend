class Milestone < ActiveRecord::Base
  belongs_to :project
  has_many :items, dependent: :destroy

  #validates :name, presence: true, length: { maximum: 30 }
end
