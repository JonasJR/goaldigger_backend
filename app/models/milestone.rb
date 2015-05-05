class Milestone < ActiveRecord::Base
  belongs_to :project
  has_many :items, dependent: :destroy_all

  #validates :name, presence: true, length: { maximum: 30 }
end
