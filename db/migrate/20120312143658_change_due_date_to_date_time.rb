class ChangeDueDateToDateTime < ActiveRecord::Migration
  def up
    change_column :stickies, :due_date, :datetime
    Sticky.all.select{|s| not s.due_date.blank?}.each{|s| s.update_attributes(due_date: s.due_date.at_midnight + 1.day) }
    Sticky.all.select{|s| not s.due_date.blank? and not s.read_attribute('due_at').blank?}.each{ |s| s.update_attributes(all_day: false, due_date: s.due_date + s.read_attribute('due_at').localtime.strftime("%H").to_i.hours + s.read_attribute('due_at').localtime.strftime("%M").to_i.minutes) }
  end

  def down
    change_column :stickies, :due_date, :date
  end
end
