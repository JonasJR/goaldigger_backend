class AddDoneByToItems < ActiveRecord::Migration
  def change
    add_column :items, :done_by, :string
  end
end
