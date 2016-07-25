class AddFrameIdToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :frame_id, :integer
  end
end
