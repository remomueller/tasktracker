class AddCalendarViewToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :calendar_view, :string, null: false, default: 'month'
  end
end
