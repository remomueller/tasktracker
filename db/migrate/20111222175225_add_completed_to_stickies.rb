class AddCompletedToStickies < ActiveRecord::Migration
  def self.up
    add_column :stickies, :completed, :boolean, default: false, null: false
    Sticky.all.each{|s| s.update_attribute :completed, (s.status == 'completed')}
  end

  def self.down
    remove_column :stickies, :completed
  end
end
