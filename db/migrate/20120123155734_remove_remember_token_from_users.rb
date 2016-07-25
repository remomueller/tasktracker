class RemoveRememberTokenFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :remember_token, :string
  end
end
