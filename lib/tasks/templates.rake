# frozen_string_literal: true

namespace :templates do
  desc 'Migrate project template items string to new template_items relation'
  task migrate_items: :environment do
    Template.find_each do |template|
      puts "TEMPLATE: #{template.name}"
      template.item_hashes = template.items
      template.save
    end
  end
end
