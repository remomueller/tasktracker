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

  test 'daily digest email' do
    valid = users(:valid)
    mail = UserMailer.daily_digest(valid)
    assert_equal [valid.email], mail.to
    assert_equal "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}", mail.subject
    assert_match(/Dear #{valid.first_name},/, mail.body.encoded)
  end
end
