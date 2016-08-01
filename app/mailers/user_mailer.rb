# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
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

  def daily_digest(recipient)
    setup_email
    @recipient = recipient

    @email_to = recipient.email
    mail(to: recipient.email, subject: "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end
end
