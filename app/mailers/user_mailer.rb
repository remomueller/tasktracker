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

  def daily_digest(recipient)
    setup_email
    @recipient = recipient

    @email_to = recipient.email
    mail(to: recipient.email, subject: "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end
end
