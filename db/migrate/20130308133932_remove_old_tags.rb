class RemoveOldTags < ActiveRecord::Migration[4.2]
  def change
    remove_column :stickies, :old_tags, :text
    remove_column :projects, :old_tags, :text
  end
end
