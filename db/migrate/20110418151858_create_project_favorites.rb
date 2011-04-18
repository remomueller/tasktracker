class CreateProjectFavorites < ActiveRecord::Migration
  def self.up
    create_table :project_favorites do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :favorite, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :project_favorites
  end
end
