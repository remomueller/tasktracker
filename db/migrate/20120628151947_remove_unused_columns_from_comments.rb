class RemoveUnusedColumnsFromComments < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :class_name, :string
    remove_column :comments, :class_id, :integer
  end
end
