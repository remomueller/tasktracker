class RemoveEmailNotificationsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :email_notifications, :text
  end
end
