# frozen_string_literal: true

namespace :emails do
  desc 'Migrate user email settings'
  task migrate_settings: :environment do
    User.find_each do |user|
      user.update emails_enabled: user.email_on?(:send_email)
      user.all_viewable_projects.each do |project|
        emails_enabled = user.email_on?("project_#{project.id}")
        project_favorite = project.project_favorites.where(user_id: user.id).first_or_create
        project_favorite.update emails_enabled: emails_enabled
        puts "#{user.name}   #{project.name}   #{emails_enabled ? 'EMAILS ON' : 'EMAILS OFF'.colorize(:red)}"
      end
    end
  end
end
