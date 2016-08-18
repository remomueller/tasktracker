class RemoveUnusedUserColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :stickies_per_page, :integer, null: false, default: 10
    remove_column :users, :projects_per_page, :integer, null: false, default: 10
    remove_column :users, :boards_per_page, :integer, null: false, default: 10
    remove_column :users, :comments_per_page, :integer, null: false, default: 10
    remove_column :users, :users_per_page, :integer, null: false, default: 10
    remove_column :users, :templates_per_page, :integer, null: false, default: 10
    remove_column :users, :groups_per_page, :integer, null: false, default: 10
  end
end
