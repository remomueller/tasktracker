class AddOwnerIdToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :owner_id, :integer
  end
end
