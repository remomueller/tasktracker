class RemoveItemsFromTemplates < ActiveRecord::Migration
  def change
    remove_column :templates, :items, :text
  end
end
