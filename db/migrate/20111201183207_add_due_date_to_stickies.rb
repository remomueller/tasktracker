class AddDueDateToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :due_date, :date
  end
end
