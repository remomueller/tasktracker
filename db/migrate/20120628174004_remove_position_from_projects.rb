class RemovePositionFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :position, :integer, null: false, default: 0
  end
end
