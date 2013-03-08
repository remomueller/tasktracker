class RemoveOldTags < ActiveRecord::Migration
  def up
    remove_column :stickies, :old_tags
    remove_column :projects, :old_tags
  end

  def down
    add_column :stickies, :old_tags, :text
    add_column :projects, :old_tags, :text
  end
end
