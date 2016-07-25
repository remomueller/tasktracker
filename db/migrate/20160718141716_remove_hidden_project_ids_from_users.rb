class RemoveHiddenProjectIdsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :hidden_project_ids, :text
  end
end
