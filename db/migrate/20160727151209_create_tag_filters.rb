class CreateTagFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_filters do |t|
      t.integer :user_id
      t.integer :tag_id
      t.timestamps
    end
    add_index :tag_filters, [:user_id, :tag_id], unique: true
  end
end
