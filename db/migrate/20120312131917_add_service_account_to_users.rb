class AddServiceAccountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :service_account, :boolean, null: false, default: false
  end
end
