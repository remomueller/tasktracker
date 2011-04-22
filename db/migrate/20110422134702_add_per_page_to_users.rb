class AddPerPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :projects_per_page, :integer, :null => false, :default => 10
    add_column :users, :frames_per_page, :integer, :null => false, :default => 10
    add_column :users, :comments_per_page, :integer, :null => false, :default => 10
    add_column :users, :users_per_page, :integer, :null => false, :default => 10
  end

  def self.down
    remove_column :users, :projects_per_page
    remove_column :users, :frames_per_page
    remove_column :users, :comments_per_page
    remove_column :users, :users_per_page
  end
end
