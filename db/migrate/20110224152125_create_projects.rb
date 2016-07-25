class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.integer :user_id
      t.integer :position, null: false, default: 0
      t.string :name
      t.string :status, null: false, default: 'ongoing'
      t.text :description
      t.date :start_date
      t.date :end_date
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
