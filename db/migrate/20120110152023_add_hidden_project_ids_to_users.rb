class AddHiddenProjectIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hidden_project_ids, :text
  end
end
