class AddOwnerIdToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :owner_id, :integer
  end
end
