class RenameFramesToBoards < ActiveRecord::Migration[4.2]
  def up
    remove_index :frames, :project_id
    remove_index :frames, :user_id
    rename_table :frames, :boards
    add_index :boards, :project_id
    add_index :boards, :user_id

    remove_index  :stickies, :frame_id
    rename_column :stickies, :frame_id, :board_id
    add_index     :stickies, :board_id

    rename_column :users, :frames_per_page, :boards_per_page
  end

  def down
    rename_column :users, :boards_per_page, :frames_per_page

    remove_index :boards, :project_id
    remove_index :boards, :user_id
    rename_table :boards, :frames
    add_index :frames, :project_id
    add_index :frames, :user_id

    remove_index  :stickies, :board_id
    rename_column :stickies, :board_id, :frame_id
    add_index     :stickies, :frame_id
  end
end
