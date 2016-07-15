class UserSystemAdmin < ActiveRecord::Migration
  def change
    add_column :users, :system_admin, :boolean, null: false, default: false
  end
end
