desc 'Launched by crontab -e, send a reminder email to users who may have tasks due for the day.'
task :reminder_email => :environment do
  # At 1am every week day, in production mode, for users who have "daily tasks due" email notification selected
  User.current.each do |user|
    if user.all_deliverable_stickies_due_today.size + user.all_deliverable_stickies_past_due.size + user.all_deliverable_stickies_due_upcoming.size > 0
      UserMailer.daily_stickies_due(user).deliver_later if Rails.env.production? and user.email_on?(:daily_stickies_due) and (1..5).include?(Date.today.wday)
    end

    if user.digest_stickies_created.size + user.digest_stickies_completed.size + user.digest_comments.size > 0
      UserMailer.daily_digest(user).deliver_later if Rails.env.production? and user.email_on?(:daily_digest) and (1..5).include?(Date.today.wday)
    end
  end
end
