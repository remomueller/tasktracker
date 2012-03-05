class AddAvoidWeekendsToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :avoid_weekends, :boolean, null: false, default: false
  end
end
