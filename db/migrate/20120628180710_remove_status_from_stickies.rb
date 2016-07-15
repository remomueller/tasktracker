class RemoveStatusFromStickies < ActiveRecord::Migration
  def change
    remove_column :stickies, :status, :string, null: false, default: 'ongoing'
  end
end
