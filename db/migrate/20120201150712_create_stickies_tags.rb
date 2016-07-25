class CreateStickiesTags < ActiveRecord::Migration[4.2]
  def change
    create_table :stickies_tags, id: false do |t|
      t.integer :sticky_id
      t.integer :tag_id
    end

    add_index :stickies_tags, :sticky_id
    add_index :stickies_tags, :tag_id
  end
end
