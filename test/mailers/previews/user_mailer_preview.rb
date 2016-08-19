# frozen_string_literal: true

# Allows emails to be viewed at /rails/mailers
class UserMailerPreview < ActionMailer::Preview
  def user_added_to_project
    project_user = ProjectUser.where(invite_email: nil).first
    UserMailer.user_added_to_project(project_user)
  end

  def invite_user_to_project
    project_user = ProjectUser.where.not(invite_email: nil).first
    UserMailer.invite_user_to_project(project_user)
  end

  def sticky_by_mail
    sticky = Sticky.current.first
    recipient = User.current.first
    UserMailer.sticky_by_mail(sticky, recipient)
  end

  def group_by_mail
    group = Group.current.first
    recipient = User.current.first
    UserMailer.group_by_mail(group, recipient)
  end

  def daily_digest
    recipient = User.current.first
    UserMailer.daily_digest(recipient)
  end
end
