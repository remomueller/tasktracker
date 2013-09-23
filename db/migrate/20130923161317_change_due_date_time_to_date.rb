class ChangeDueDateTimeToDate < ActiveRecord::Migration
  def up
    rename_column :stickies, :due_date, :due_at
    add_column :stickies, :due_date, :date
    add_index :stickies, :due_date
    add_column :stickies, :due_time, :string
    Sticky.all.where( "due_at IS NOT NULL" ).each do |s|
      s.update_column :due_date, s.due_at.to_date
      s.update_column :due_time , s.due_at.strftime("%l:%M %p").strip unless s.all_day?
    end
  end

  def down
    remove_column :stickies, :due_time
    remove_index :stickies, :due_date
    remove_column :stickies, :due_date, :date
    rename_column :stickies, :due_at, :due_date
  end
end
