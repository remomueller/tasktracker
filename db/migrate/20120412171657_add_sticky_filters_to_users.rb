class AddStickyFiltersToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sticky_filters, :text
  end
end
