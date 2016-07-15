class ChangeDueDateToDateTime < ActiveRecord::Migration
  def up
    change_column :stickies, :due_date, :datetime
  end

  def down
    change_column :stickies, :due_date, :date
  end
end
