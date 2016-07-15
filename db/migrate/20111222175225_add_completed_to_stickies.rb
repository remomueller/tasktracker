class AddCompletedToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :completed, :boolean, default: false, null: false
  end
end
