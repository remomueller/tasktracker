class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.boolean :read, null: false, default: false
      t.integer :project_id
      t.integer :comment_id
      t.integer :sticky_id
      t.integer :group_id
      t.timestamps
      t.index :user_id
      t.index :read
      t.index :project_id
      t.index :comment_id
      t.index :sticky_id
      t.index :group_id
    end
  end
end
