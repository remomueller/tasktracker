class AddStickyIdToComments < ActiveRecord::Migration
  def up
    add_column :comments, :sticky_id, :integer
    add_index :comments, :sticky_id

    Comment.where(class_name: 'Sticky').each{ |c| c.update_attribute :sticky_id, c.class_id }
  end

  def down
    remove_index :comments, :sticky_id
    remove_column :comments, :sticky_id
  end
end
