class RemoveScreenToken < ActiveRecord::Migration
  def change
    remove_column :users, :screen_token, :string
  end
end
