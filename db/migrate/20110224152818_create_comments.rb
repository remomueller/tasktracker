class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id
      t.string :object_model
      t.integer :object_id
      t.text :description
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
