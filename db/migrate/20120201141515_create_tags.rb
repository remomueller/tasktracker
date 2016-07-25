class CreateTags < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :tags, :old_tags
    rename_column :stickies, :tags, :old_tags

    create_table :tags do |t|
      t.string :name
      t.text :description
      t.string :color, default: '#dddddd', null: false
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end

    add_index :tags, :project_id
    add_index :tags, :user_id
  end
end
