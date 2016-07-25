class AddArchivedToBoards < ActiveRecord::Migration[4.2]
  def change
    add_column :boards, :archived, :boolean, null: false, default: false
  end
end
