class AddPerPageToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :projects_per_page, :integer, null: false, default: 10
    add_column :users, :frames_per_page, :integer, null: false, default: 10
    add_column :users, :comments_per_page, :integer, null: false, default: 10
    add_column :users, :users_per_page, :integer, null: false, default: 10
  end
end
