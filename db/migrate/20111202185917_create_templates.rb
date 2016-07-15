class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.integer :user_id
      t.integer :project_id
      t.text :items
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
