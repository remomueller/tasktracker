class AddStickiesPerPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :stickies_per_page, :integer, :null => false, :default => 10
  end

  def self.down
    remove_column :users, :stickies_per_page
  end
end
