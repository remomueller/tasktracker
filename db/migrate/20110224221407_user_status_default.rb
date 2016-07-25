class UserStatusDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :status, :string, null: false, default: 'pending'
  end

  def down
    change_column :users, :status, :string
  end
end
