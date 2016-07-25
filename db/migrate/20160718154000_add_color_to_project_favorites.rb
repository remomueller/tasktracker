class AddColorToProjectFavorites < ActiveRecord::Migration[4.2]
  def change
    add_column :project_favorites, :color, :string
  end
end
