class AddStickiesPerPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stickies_per_page, :integer, null: false, default: 10
  end
end
