class AddStickyIdToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :sticky_id, :integer
    add_index :comments, :sticky_id
  end
end
