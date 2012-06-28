class RemovePositionFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :position
  end

  def down
    add_column :projects, :position, :integer, null: false, default: 0
  end
end
