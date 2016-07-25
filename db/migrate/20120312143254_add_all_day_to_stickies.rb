class AddAllDayToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :all_day, :boolean, default: true, null: false
  end
end
