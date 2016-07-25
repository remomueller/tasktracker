class AddHiddenProjectIdsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :hidden_project_ids, :text
  end
end
