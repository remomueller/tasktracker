class AddServiceAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :service_account, :boolean, null: false, default: false
  end
end
