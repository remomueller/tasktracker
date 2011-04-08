class CreateFrames < ActiveRecord::Migration
  def self.up
    create_table :frames do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :frames
  end
end
