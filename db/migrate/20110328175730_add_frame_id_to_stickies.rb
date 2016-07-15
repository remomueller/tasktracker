class AddFrameIdToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :frame_id, :integer
  end
end
