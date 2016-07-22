class AddEmailsEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :emails_enabled, :boolean, null: false, default: false
    add_index :users, :emails_enabled
  end
end
