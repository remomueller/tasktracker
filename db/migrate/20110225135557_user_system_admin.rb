class UserSystemAdmin < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :system_admin, :boolean, null: false, default: false
  end
end
