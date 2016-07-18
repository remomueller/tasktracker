class RemoveStatusFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :status, :string, null: false, default: 'pending'
  end
end
