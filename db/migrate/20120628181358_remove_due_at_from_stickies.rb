class RemoveDueAtFromStickies < ActiveRecord::Migration
  def up
    remove_column :stickies, :due_at
  end

  def down
    add_column :stickies, :due_at, :time
  end
end
