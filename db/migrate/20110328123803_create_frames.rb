class CreateFrames < ActiveRecord::Migration[4.2]
  def change
    create_table :frames do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
