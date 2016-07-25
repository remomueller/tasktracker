class RemoveServiceAccountFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :service_account, :boolean, default: false, null: false
  end
end
