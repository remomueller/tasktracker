class CreateTemplateItemTags < ActiveRecord::Migration
  def change
    create_table :template_item_tags do |t|
      t.integer :template_item_id
      t.integer :tag_id

      t.timestamps null: false
    end
    add_index :template_item_tags, [:template_item_id, :tag_id], unique: true
  end
end
