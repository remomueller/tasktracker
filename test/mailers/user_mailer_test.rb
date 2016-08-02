# frozen_string_literal: true

require 'test_helper'

# Tests that mail views are rendered corretly, sent to correct user, and have a
# correct subject line
class UserMailerTest < ActionMailer::TestCase
  test 'user added to project email' do
    project_user = project_users(:accepted_viewer_invite)
    mail = UserMailer.user_added_to_project(project_user)
    assert_equal [project_user.user.email], mail.to
    assert_equal "#{project_user.creator.name} Allows You to View #{project_user.project.name}", mail.subject
    assert_match(/#{project_user.creator.name} added you to #{project_user.project.name}/, mail.body.encoded)
  end

  test 'user invited to project email' do
    project_user = project_users(:pending_editor_invite)
    mail = UserMailer.invite_user_to_project(project_user)
    assert_equal [project_user.invite_email], mail.to
    assert_equal "#{project_user.creator.name} Invites You to Edit #{project_user.project.name}", mail.subject
    assert_match(/#{project_user.creator.name} invited you to #{project_user.project.name}/, mail.body.encoded)
  end

  test 'comment by mail email' do
    comment = comments(:two)
    sticky = comment.sticky
    valid = users(:valid)
    mail = UserMailer.comment_by_mail(comment, sticky, valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{comment.user.name} Commented on Task #{sticky.name}", mail.subject
    assert_match(/#{comment.user.name} COMMENTED on Task #{sticky.name} located at #{ENV['website_url']}\/stickies\/#{sticky.id}\./, mail.body.encoded)
  end

  test 'sticky by mail email' do
    sticky = stickies(:one)
    valid = users(:valid)
    mail = UserMailer.sticky_by_mail(sticky, valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{sticky.user.name} Added a Task to Project #{sticky.project.name}", mail.subject
    assert_match(/#{sticky.user.name} added Task #{sticky.name} #{ENV['website_url']}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{ENV['website_url']}\/projects\/#{sticky.project.id}\./, mail.body.encoded)
  end

  test 'task completion by mail email' do
    sticky = stickies(:assigned_to_user)
    valid = users(:valid)
    sender = users(:valid)
    mail = UserMailer.sticky_completion_by_mail(sticky, sender, valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{sender.name} Completed a Task on Project #{sticky.project.name}", mail.subject
    assert_match(/#{sender.name} completed the following Task #{sticky.name} #{ENV['website_url']}\/stickies\/#{sticky.id} on Project #{sticky.project.name} #{ENV['website_url']}\/projects\/#{sticky.project.id}\./, mail.body.encoded)
  end

  test 'tasks completion by mail email' do
    stickies = Sticky.where(id: stickies(:assigned_to_user).id)
    valid = users(:valid)
    sender = users(:valid)
    mail = UserMailer.stickies_completion_by_mail(stickies, sender, valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{sender.name} Completed 1 Task", mail.subject
    assert_match(/#{sender.name} completed the following 1 Task\./, mail.body.encoded)
  end

  test 'group by mail email' do
    group = groups(:one)
    valid = users(:valid)
    mail = UserMailer.group_by_mail(group, valid)
    assert_equal [valid.email], mail.to
    assert_equal "#{group.user.name} Added a Group of Tasks to Project #{group.template.project.name}", mail.subject
    assert_match(/#{group.user.name} added Group #{group.name} #{ENV['website_url']}\/groups\/#{group.id} with #{group.stickies.size} #{group.stickies.size == 1 ? 'Task' : 'Tasks'}#{" from Template #{group.template.name}" if group.template}\./, mail.body.encoded)
  end

  test 'daily digest email' do
    valid = users(:valid)
    mail = UserMailer.daily_digest(valid)
    assert_equal [valid.email], mail.to
    assert_equal "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}", mail.subject
    assert_match(/Dear #{valid.first_name},/, mail.body.encoded)
  end
end
