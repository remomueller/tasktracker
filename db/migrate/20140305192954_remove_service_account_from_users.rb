class RemoveServiceAccountFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :service_account, :boolean, default: false, null: false
  end
end
