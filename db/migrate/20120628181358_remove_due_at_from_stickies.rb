class RemoveDueAtFromStickies < ActiveRecord::Migration[4.2]
  def change
    remove_column :stickies, :due_at, :time
  end
end
