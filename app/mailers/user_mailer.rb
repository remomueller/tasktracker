class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    @email_to = system_admin.email
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def status_activated(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email,
         subject: "#{user.name}'s Account Activated") #,
#         reply_to: user.email)
  end

  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.user.email
    mail(to: project_user.user.email,
         subject: "#{project_user.creator.name} Allows You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def invite_user_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.invite_email
    mail(to: project_user.invite_email,
         subject: "#{project_user.creator.name} Invites You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def comment_by_mail(comment, sticky, recipient)
    setup_email
    @comment = comment
    @sticky = sticky
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{comment.user.name} Commented on Task #{sticky.name}",
         reply_to: comment.user.email)
  end

  def sticky_by_mail(sticky, recipient)
    setup_email
    @sticky = sticky
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{sticky.user.name} Added a Task to Project #{sticky.project.name}",
         reply_to: sticky.user.email)
  end

  def group_by_mail(group, recipient)
    setup_email
    @group = group
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{group.user.name} Added a Group of Tasks to Project #{group.template.project.name}",
         reply_to: group.user.email)
  end

  def sticky_completion_by_mail(sticky, sender, recipient)
    setup_email
    @sticky = sticky
    @sender = sender
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{sender.name} Completed a Task on Project #{sticky.project.name}",
         reply_to: sender.email)
  end

  def stickies_completion_by_mail(stickies, sender, recipient)
    setup_email
    @stickies = stickies
    @sender = sender
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{sender.name} Completed #{@stickies.count} #{@stickies.count == 1 ? 'Task' : 'Tasks'}",
         reply_to: sender.email)
  end

  def daily_stickies_due(recipient)
    setup_email
    @recipient = recipient
    due_today = "#{recipient.all_deliverable_stickies_due_today.size} " + (recipient.all_deliverable_stickies_due_today.size == 1 ? 'Task' : 'Tasks') + " Due Today"
    past_due = "#{recipient.all_deliverable_stickies_past_due.size} " + (recipient.all_deliverable_stickies_past_due.size == 1 ? 'Task' : 'Tasks') + " Past Due"
    due_upcoming = "#{recipient.all_deliverable_stickies_due_upcoming.size} " + (recipient.all_deliverable_stickies_due_upcoming.size == 1 ? 'Task' : 'Tasks') + " Upcoming"
    due_today = nil if recipient.all_deliverable_stickies_due_today.size == 0
    past_due = nil if recipient.all_deliverable_stickies_past_due.size == 0
    due_upcoming = nil if recipient.all_deliverable_stickies_due_upcoming.size == 0

    @email_to = recipient.email
    mail(to: recipient.email,
         subject: [due_today, past_due, due_upcoming].compact.join(' and '))
  end

  def daily_digest(recipient)
    setup_email
    @recipient = recipient

    @email_to = recipient.email
    # if @recipient.digest_stickies_created.size + @recipient.digest_stickies_completed.size + @recipient.digest_comments.size > 0
      mail(to: recipient.email, subject: "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}")
    # end
  end

  protected

  def setup_email
    @footer_html = "<div style=\"color:#777\">Change #{DEFAULT_APP_NAME} email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a></div><br /><br />".html_safe
    @footer_txt = "Change #{DEFAULT_APP_NAME} email settings here: #{SITE_URL}/settings"
  end
end
