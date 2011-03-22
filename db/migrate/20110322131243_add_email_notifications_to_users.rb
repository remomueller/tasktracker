class AddEmailNotificationsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_notifications, :binary
  end

  def self.down
    remove_column :users, :email_notifications
  end
end
