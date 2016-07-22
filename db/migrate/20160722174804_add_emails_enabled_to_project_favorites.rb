class AddEmailsEnabledToProjectFavorites < ActiveRecord::Migration
  def change
    add_column :project_favorites, :emails_enabled, :boolean, null: false, default: true
    add_index :project_favorites, :emails_enabled
  end
end
