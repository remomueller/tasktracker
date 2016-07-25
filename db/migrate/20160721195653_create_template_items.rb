class CreateTemplateItems < ActiveRecord::Migration[4.2]
  def change
    create_table :template_items do |t|
      t.integer :template_id
      t.integer :position, null: false, default: 0
      t.text :description
      t.integer :interval, null: false, default: 0
      t.string :interval_units, null: false, default: 'days'
      t.integer :owner_id
      t.string :due_time
      t.integer :duration, null: false, default: 0
      t.string :duration_units, null: false, default: 'hours'

      t.timestamps null: false
    end

    add_index :template_items, :template_id
    add_index :template_items, :position
    add_index :template_items, :owner_id
  end
end
