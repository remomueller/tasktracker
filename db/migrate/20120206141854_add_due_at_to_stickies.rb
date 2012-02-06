class AddDueAtToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :due_at, :time
    add_column :stickies, :duration, :integer, null: false, default: 0
    add_column :stickies, :duration_units, :string, null: false, default: 'hours'
  end
end
