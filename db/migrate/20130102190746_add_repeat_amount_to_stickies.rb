class AddRepeatAmountToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :repeat_amount, :integer, default: 1, null: false
  end
end
