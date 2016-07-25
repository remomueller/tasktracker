class RemoveScreenToken < ActiveRecord::Migration[4.2]
  def up
    remove_index :users, column: :screen_token, unique: true
    remove_column :users, :screen_token, :string
  end

  def down
    add_column :users, :screen_token, :string
    add_index :users, :screen_token, unique: true
  end
end
