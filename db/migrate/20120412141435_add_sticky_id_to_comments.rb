class AddStickyIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :sticky_id, :integer
    add_index :comments, :sticky_id
  end
end
