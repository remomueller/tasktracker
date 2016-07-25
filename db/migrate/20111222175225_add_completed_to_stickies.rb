class AddCompletedToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :completed, :boolean, default: false, null: false
  end
end
