class AddCalendarTaskStatusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :calendar_task_status, :boolean
  end
end
