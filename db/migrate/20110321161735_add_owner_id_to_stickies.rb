class AddOwnerIdToStickies < ActiveRecord::Migration
  def self.up
    add_column :stickies, :owner_id, :integer
  end

  def self.down
    remove_column :stickies, :owner_id
  end
end
