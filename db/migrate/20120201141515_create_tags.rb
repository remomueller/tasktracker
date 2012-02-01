class CreateTags < ActiveRecord::Migration
  def up
    rename_column :projects, :tags, :old_tags
    rename_column :stickies, :tags, :old_tags

    create_table :tags do |t|
      t.string :name
      t.text :description
      t.string :color, default: "#dddddd", null: false
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end

    add_index :tags, :project_id
    add_index :tags, :user_id

    Project.all.each do |project|
      project.old_tags.compact.uniq.each do |old_tag|
        project.tags.create({ name: old_tag, user_id: project.user_id })
      end
    end

    Template.all.each do |template|
      template.items.each do |item|
        tag_ids = []
        (item[:tags] || []).each do |tag_name|
          tag = template.project.tags.find_by_name(tag_name)
          tag_ids << tag.id if tag
        end
        item[:tag_ids] = tag_ids
      end
      template.save
    end

  end

  def down
    drop_table :tags
    rename_column :projects, :old_tags, :tags
    rename_column :stickies, :old_tags, :tags
  end
end
