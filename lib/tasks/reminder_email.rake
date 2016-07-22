# frozen_string_literal: true

desc 'Launched by crontab -e, send a reminder email to users who may have tasks due for the day.'
task reminder_email: :environment do
  return unless EMAILS_ENABLED
  return unless (1..5).cover?(Time.zone.today.wday)
  # At 1am every week day, in production mode, for users who have "daily tasks due" email notification selected
  # TODO: Combine daily digest emails together into single digest email.
  User.current.where(emails_enabled: true).each do |user|
    if user.all_deliverable_stickies_due_today.size + user.all_deliverable_stickies_past_due.size + user.all_deliverable_stickies_due_upcoming.size > 0
      UserMailer.daily_stickies_due(user).deliver_now
    end

    if user.digest_stickies_created.size + user.digest_stickies_completed.size + user.digest_comments.size > 0
      UserMailer.daily_digest(user).deliver_now
    end
  end
end
