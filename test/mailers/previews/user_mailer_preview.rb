# frozen_string_literal: true

# Allows emails to be viewed at /rails/mailers
class UserMailerPreview < ActionMailer::Preview
  def user_added_to_project
    project_user = ProjectUser.where(invite_email: nil).first
    UserMailer.user_added_to_project(project_user)
  end

  def invite_user_to_project
    project_user = ProjectUser.where.not( invite_email: nil ).first
    UserMailer.invite_user_to_project(project_user)
  end

  def comment_by_mail
    comment = Comment.current.first
    sticky = comment.sticky
    recipient = User.current.first
    UserMailer.comment_by_mail(comment, sticky, recipient)
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

  def sticky_completion_by_mail
    sticky = Sticky.current.first
    recipient = User.current.first
    sender = User.current.first
    UserMailer.sticky_completion_by_mail(sticky, sender, recipient)
  end

  def stickies_completion_by_mail
    stickies = Sticky.current.limit(2)
    recipient = User.current.first
    sender = User.current.first
    UserMailer.stickies_completion_by_mail(stickies, sender, recipient)
  end

  def daily_stickies_due
    recipient = User.current.first
    UserMailer.daily_stickies_due(recipient)
  end

  def daily_digest
    recipient = User.current.first
    UserMailer.daily_digest(recipient)
  end
end
