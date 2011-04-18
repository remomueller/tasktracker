class AddFavoriteToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :favorite, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :projects, :favorite
  end
end
