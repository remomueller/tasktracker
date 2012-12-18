class AddRepeatToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :repeat, :string, null: false, default: 'none'
    add_column :stickies, :repeated_sticky_id, :integer

    add_index :stickies, :repeated_sticky_id
  end
end
