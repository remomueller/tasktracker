class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.text :description
      t.integer :user_id
      t.integer :template_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
