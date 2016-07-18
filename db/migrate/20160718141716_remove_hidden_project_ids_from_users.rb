class RemoveHiddenProjectIdsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :hidden_project_ids, :text
  end
end
