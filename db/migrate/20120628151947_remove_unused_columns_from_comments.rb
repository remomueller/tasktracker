class RemoveUnusedColumnsFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :class_name
    remove_column :comments, :class_id
  end

  def down
    add_column :comments, :class_name, :string
    add_column :comments, :class_id, :integer
  end
end
