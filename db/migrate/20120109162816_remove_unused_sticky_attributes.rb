class RemoveUnusedStickyAttributes < ActiveRecord::Migration[4.2]
  def change
    remove_column :stickies, :sticky_id, :integer
    remove_column :stickies, :position, :integer, default: 0, null: false
    remove_column :stickies, :sticky_type, :string, default: 'generic', null: false
  end
end
