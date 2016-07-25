class AddRepeatAmountToStickies < ActiveRecord::Migration[4.2]
  def change
    add_column :stickies, :repeat_amount, :integer, default: 1, null: false
  end
end
