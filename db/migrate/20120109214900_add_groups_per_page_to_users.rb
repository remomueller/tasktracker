class AddGroupsPerPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :groups_per_page, :integer, null: false, default: 10
  end
end
