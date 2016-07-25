class AddAvoidWeekendsToTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :templates, :avoid_weekends, :boolean, null: false, default: false
  end
end
