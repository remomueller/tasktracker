class AddGroupsPerPageToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :groups_per_page, :integer, null: false, default: 10
  end
end
