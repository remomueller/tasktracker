class ChangeDueDateToDateTime < ActiveRecord::Migration
  def up
    change_column :stickies, :due_date, :datetime
    Sticky.all.select{|s| not s.due_at.blank?}.each{|s| s.update_attributes(due_date: Time.parse(s.due_date.strftime("%Y-%m-%d ") + s.due_at.strftime("%l:%M %p")), all_day: false ) }
  end

  def down
    change_column :stickies, :due_date, :date
  end
end
