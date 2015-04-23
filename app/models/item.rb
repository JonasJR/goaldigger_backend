class Item < ActiveRecord::Base
  belongs_to :project
  belongs_to :milestone
  belongs_to :user
end
