class CreateStickies < ActiveRecord::Migration
  def self.up
    create_table :stickies do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :sticky_id
      t.integer :position, :null => false, :default => 0
      t.string :status, :null => false, :default => 'ongoing'
      t.string :sticky_type, :null => false, :default => 'update'
      t.text :description
      t.date :start_date
      t.date :end_date
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :stickies
  end
end
