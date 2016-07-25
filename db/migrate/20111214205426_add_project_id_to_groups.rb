class AddProjectIdToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :project_id, :integer
  end
end
