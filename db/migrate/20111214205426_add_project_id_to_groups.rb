class AddProjectIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :project_id, :integer
  end
end
