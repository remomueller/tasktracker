class AddEmailNotificationsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_notifications, :binary
  end
end
