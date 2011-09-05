class ChangeObjectIdInComments < ActiveRecord::Migration
  def up
    rename_column :comments, :object_id, :class_id
    rename_column :comments, :object_model, :class_name
  end

  def down
    rename_column :comments, :class_id, :object_id
    rename_column :comments, :class_name, :object_model
  end
end
