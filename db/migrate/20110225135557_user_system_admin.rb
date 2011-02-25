class UserSystemAdmin < ActiveRecord::Migration
  def self.up
    add_column :users, :system_admin, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :system_admin
  end
end
