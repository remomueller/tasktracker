class AddTagsToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :tags, :text
  end
end
