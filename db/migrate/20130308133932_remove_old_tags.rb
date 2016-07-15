class RemoveOldTags < ActiveRecord::Migration
  def change
    remove_column :stickies, :old_tags, :text
    remove_column :projects, :old_tags, :text
  end
end
