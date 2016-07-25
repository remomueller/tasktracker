class AddScreenTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :screen_token, :string
    add_index :users, :screen_token, unique: true
  end
end
