class AddEmailNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_notifications, :binary
  end
end
