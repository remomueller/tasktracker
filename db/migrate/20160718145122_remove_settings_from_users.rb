class RemoveSettingsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :settings, :text
  end
end
