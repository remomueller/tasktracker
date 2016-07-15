class ChangeDueDateTimeToDate < ActiveRecord::Migration
  def change
    rename_column :stickies, :due_date, :due_at
    add_column :stickies, :due_date, :date
    add_index :stickies, :due_date
    add_column :stickies, :due_time, :string
  end
end
