desc 'Launched by crontab -e, send a reminder email to users who may have tasks due for the day.'
task :reminder_email => :environment do
  # At 1am every week day, in production mode, for users who have "daily stickies due" email notification selected
  User.current.each do |user|
    if user.all_deliverable_stickies_due_today.size + user.all_deliverable_stickies_past_due.size > 0
      UserMailer.daily_stickies_due(user).deliver if Rails.env.production? and user.active_for_authentication? and user.email_on?(:daily_stickies_due) and (1..5).include?(Date.today.wday)
    end
  end
end