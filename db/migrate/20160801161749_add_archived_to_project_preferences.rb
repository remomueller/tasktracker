class AddArchivedToProjectPreferences < ActiveRecord::Migration[5.0]
  def change
    add_column :project_preferences, :archived, :boolean, null: false, default: false
    add_index :project_preferences, :archived
  end
end
