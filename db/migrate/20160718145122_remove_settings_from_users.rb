class RemoveSettingsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :settings, :text
  end
end
