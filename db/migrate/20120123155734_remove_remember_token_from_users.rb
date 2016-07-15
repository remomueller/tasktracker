class RemoveRememberTokenFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :remember_token, :string
  end
end
