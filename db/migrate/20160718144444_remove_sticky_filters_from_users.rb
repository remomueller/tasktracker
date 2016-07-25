class RemoveStickyFiltersFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :sticky_filters, :text
  end
end
