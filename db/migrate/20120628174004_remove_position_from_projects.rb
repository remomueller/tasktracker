class RemovePositionFromProjects < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :position, :integer, null: false, default: 0
  end
end
