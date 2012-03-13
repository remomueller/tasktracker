class ChangeDueDateToDateTime < ActiveRecord::Migration
  def up
    change_column :stickies, :due_date, :datetime
    Sticky.all.select{|s| not s.due_at.blank?}.each{ |s| s.update_attributes(description: s.description + "\n\nDUE AT: " + s.due_at.localtime.strftime("%l:%M %p").strip) }
  end

  def down
    change_column :stickies, :due_date, :date
  end
end
