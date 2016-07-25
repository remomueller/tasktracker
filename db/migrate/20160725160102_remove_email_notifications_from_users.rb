class RemoveEmailNotificationsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :email_notifications, :text
  end
end
