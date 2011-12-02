class AddTemplatesPerPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :templates_per_page, :integer, :null => false, :default => 10
  end
end
