class AddCompleterIdToStickies < ActiveRecord::Migration[5.0]
  def change
    add_column :stickies, :completer_id, :integer
    add_index :stickies, :completer_id
  end
end
