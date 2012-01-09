class RemoveUnusedStickyAttributes < ActiveRecord::Migration
  def up
    remove_column :stickies, :sticky_id
    remove_column :stickies, :position
    remove_column :stickies, :sticky_type
  end

  def down
    add_column :stickies, :sticky_id, :integer
    add_column :stickies, :position, :integer, default: 0, null: false
    add_column :stickies, :sticky_type, :string, default: "generic", null: false
  end
end
