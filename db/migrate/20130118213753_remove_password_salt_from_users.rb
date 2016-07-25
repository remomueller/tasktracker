class RemovePasswordSaltFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :password_salt, :string, default: '', null: false
  end
end
