class AddTagsToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :tags, :text
  end
end
