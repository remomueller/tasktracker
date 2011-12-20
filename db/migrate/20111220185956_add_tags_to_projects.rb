class AddTagsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tags, :text
  end
end
