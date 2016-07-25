class RemoveItemsFromTemplates < ActiveRecord::Migration[4.2]
  def change
    remove_column :templates, :items, :text
  end
end
