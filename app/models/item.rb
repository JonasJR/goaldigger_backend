class Item < ActiveRecord::Base
  belongs_to :milestone
  belongs_to :user

  #validates :name, presence: true, length: { maximum: 30 }
end
