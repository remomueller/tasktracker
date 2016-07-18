class AddColorToProjectFavorites < ActiveRecord::Migration
  def change
    add_column :project_favorites, :color, :string
  end
end
