class UserStatusDefault < ActiveRecord::Migration
  def self.up
    change_column :users, :status, :string, :null => false, :default => 'pending'
  end

  def self.down
    change_column :users, :status, :string
  end
end
