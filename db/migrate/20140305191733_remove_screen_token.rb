class RemoveScreenToken < ActiveRecord::Migration
  def change
    remove_index :users, column: :screen_token, unique: true
    remove_column :users, :screen_token, :string
  end
end
