class CreateProjectFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :project_filters do |t|
      t.integer :user_id
      t.integer :project_id
      t.timestamps
    end
    add_index :project_filters, [:user_id, :project_id], unique: true
  end
end
