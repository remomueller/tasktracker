class UserMailer < ActionMailer::Base
  default from: ActionMailer::Base.smtp_settings[:user_name]
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(to: system_admin.email,
         subject: @subject + "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def status_activated(user)
    setup_email
    @user = user
    mail(to: user.email,
         subject: @subject + "#{user.name}'s Account Activated") #,
#         reply_to: user.email)
  end

  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    mail(to: project_user.user.email,
         subject: @subject + "#{project_user.project.user.name} Allows You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}",
         reply_to: project_user.project.user.email)
  end

  def comment_by_mail(comment, object, recipient)
    setup_email
    @comment = comment
    @object = object
    @recipient = recipient
    mail(to: recipient.email,
         subject: @subject + "#{comment.user.name} Commented on #{object.class.name} #{object.name}",
         reply_to: comment.user.email)
  end

  def sticky_by_mail(sticky, recipient)
    setup_email
    @sticky = sticky
    @recipient = recipient
    attachments['event.ics'] = { mime_type: 'text/calendar', content: @sticky.export_ics } if @sticky.include_ics?
    mail(to: recipient.email,
         subject: @subject + "#{sticky.user.name} Added a Sticky to Project #{sticky.project.name}",
         reply_to: sticky.user.email)
  end

  def group_by_mail(group, recipient)
    setup_email
    @group = group
    @recipient = recipient
    attachments['event.ics'] = { mime_type: 'text/calendar', content: @group.export_ics }
    mail(to: recipient.email,
         subject: @subject + "#{group.user.name} Added a Group of Stickies to Project #{group.template.project.name}",
         reply_to: group.user.email)
  end

  def sticky_completion_by_mail(sticky, recipient)
    setup_email
    @sticky = sticky
    @recipient = recipient
    mail(to: recipient.email,
         subject: @subject + "#{sticky.owner.name} Completed a Sticky on Project #{sticky.project.name}",
         reply_to: sticky.owner.email)
  end

  def sticky_due_at_changed_by_mail(sticky, recipient)
    setup_email
    @sticky = sticky
    @recipient = recipient
    attachments['event.ics'] = { mime_type: 'text/calendar', content: @sticky.export_ics } # Always include
    mail(to: recipient.email,
         subject: @subject + "Sticky #{sticky.name} Due Time Changed on Project #{sticky.project.name}")
  end

  def daily_stickies_due(recipient)
    setup_email
    @recipient = recipient
    due_today = "#{recipient.all_deliverable_stickies_due_today.size} " + (recipient.all_deliverable_stickies_due_today.size == 1 ? 'Sticky' : 'Stickies') + " Due Today"
    past_due = "#{recipient.all_deliverable_stickies_past_due.size} " + (recipient.all_deliverable_stickies_past_due.size == 1 ? 'Sticky' : 'Stickies') + " Past Due"
    due_today = nil if recipient.all_deliverable_stickies_due_today.size == 0
    past_due = nil if recipient.all_deliverable_stickies_past_due.size == 0
    mail(to: recipient.email,
         subject: @subject + [due_today, past_due].compact.join(' and '))
  end

  protected

  def setup_email
    @subject = "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] "
    @footer_html = "Change email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a>.<br /><br />".html_safe
    @footer_txt = "Change email settings here: #{SITE_URL}/settings."
  end
end
