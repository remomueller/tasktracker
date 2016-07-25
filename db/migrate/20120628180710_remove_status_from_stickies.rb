class RemoveStatusFromStickies < ActiveRecord::Migration[4.2]
  def change
    remove_column :stickies, :status, :string, null: false, default: 'ongoing'
  end
end
