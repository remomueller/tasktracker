class ChangeObjectIdInComments < ActiveRecord::Migration[4.2]
  def change
    rename_column :comments, :object_id, :class_id
    rename_column :comments, :object_model, :class_name
  end
end
