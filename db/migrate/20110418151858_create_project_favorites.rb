class CreateProjectFavorites < ActiveRecord::Migration
  def change
    create_table :project_favorites do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :favorite, default: false, null: false

      t.timestamps
    end
  end
end
