# frozen_string_literal: true

namespace :projects do
  desc 'Migrate user colors to project favorites'
  task migrate_colors: :environment do
    User.find_each do |user|
      Project.find_each do |project|
        color = user.colors["project_#{project.id}"]
        if color.present?
          project_favorite = project.project_favorites.where(user_id: user.id).first_or_create
          project_favorite.update color: color
          puts "#{user.name}   #{project.name}   #{color}"
        end
      end
    end
  end
end
