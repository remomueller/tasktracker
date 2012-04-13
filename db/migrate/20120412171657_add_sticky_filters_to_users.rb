class AddStickyFiltersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sticky_filters, :text
  end
end
