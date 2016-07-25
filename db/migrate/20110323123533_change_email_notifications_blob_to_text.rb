class ChangeEmailNotificationsBlobToText < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :email_notifications, :text
  end

  def down
    change_column :users, :email_notifications, 'bytea USING CAST(email_notifications AS bytea)'
  end
end
