class CreateStickiesTags < ActiveRecord::Migration
  def up
    create_table :stickies_tags, id: false do |t|
      t.integer :sticky_id
      t.integer :tag_id
    end

    add_index :stickies_tags, :sticky_id
    add_index :stickies_tags, :tag_id

    Sticky.all.each do |sticky|
      sticky.old_tags.compact.uniq.each do |old_tag|
        tag = Tag.find_by_project_id_and_name(sticky.project_id, old_tag)
        sticky.tags << tag if tag
      end
    end
  end

  def down
    drop_table :stickies_tags
  end
end
