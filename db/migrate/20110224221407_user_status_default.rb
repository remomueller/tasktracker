class UserStatusDefault < ActiveRecord::Migration
  def up
    change_column :users, :status, :string, null: false, default: 'pending'
  end

  def down
    change_column :users, :status, :string
  end
end
