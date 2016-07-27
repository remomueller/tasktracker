class CreateOwnerFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :owner_filters do |t|
      t.integer :user_id
      t.integer :owner_id
      t.timestamps
    end
    add_index :owner_filters, [:user_id, :owner_id], unique: true
  end
end
