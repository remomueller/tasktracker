class RemoveStatusFromStickies < ActiveRecord::Migration
  def up
    remove_column :stickies, :status
  end

  def down
    add_column :stickies, :status, :string, null: false, default: 'ongoing'
  end
end
