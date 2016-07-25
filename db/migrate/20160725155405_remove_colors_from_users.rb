class RemoveColorsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :colors, :text
  end
end
