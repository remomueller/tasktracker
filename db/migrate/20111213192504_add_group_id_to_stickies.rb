class AddGroupIdToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :group_id, :integer
  end
end
