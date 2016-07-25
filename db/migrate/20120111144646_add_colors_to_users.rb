class AddColorsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :colors, :text
  end
end
