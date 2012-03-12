class AddAllDayToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :all_day, :boolean, default: true, null: false
  end
end
