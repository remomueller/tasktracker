class RemoveStatusFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :status, :string, null: false, default: 'pending'
  end
end
