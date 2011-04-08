class AddFrameIdToStickies < ActiveRecord::Migration
  def self.up
    add_column :stickies, :frame_id, :integer
  end

  def self.down
    remove_column :stickies, :frame_id
  end
end
