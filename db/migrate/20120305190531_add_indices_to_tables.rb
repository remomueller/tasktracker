class AddIndicesToTables < ActiveRecord::Migration
  def change
    add_index :authentications, :user_id
    add_index :comments, :user_id
    add_index :frames, :project_id
    add_index :frames, :user_id
    add_index :groups, :user_id
    add_index :project_favorites, :project_id
    add_index :project_favorites, :user_id
    add_index :project_users, :project_id
    add_index :project_users, :user_id
    add_index :projects, :user_id
    add_index :stickies, :user_id
    add_index :stickies, :project_id
    add_index :stickies, :owner_id
    add_index :stickies, :frame_id
    add_index :stickies, :group_id
    add_index :templates, :user_id
    add_index :templates, :project_id
  end
end
