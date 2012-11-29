class AddArchivedToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :archived, :boolean, null: false, default: false
  end
end
