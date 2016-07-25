class RemoveColorsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :colors, :text
  end
end
