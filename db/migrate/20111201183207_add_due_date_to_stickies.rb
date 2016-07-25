class AddDueDateToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :due_date, :date
  end
end
