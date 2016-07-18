class RemoveStickyFiltersFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :sticky_filters, :text
  end
end
