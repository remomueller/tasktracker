class RemoveDueAtFromStickies < ActiveRecord::Migration
  def change
    remove_column :stickies, :due_at, :time
  end
end
