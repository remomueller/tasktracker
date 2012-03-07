require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "notify system admin email" do
    valid = users(:valid)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.notify_system_admin(admin, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end

  test "status activated email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test "user added to project email" do
    project_user = project_users(:one)

    email = UserMailer.user_added_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.user.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{project_user.project.user.name} Allows You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}", email.subject
    assert_match(/#{project_user.project.user.name} has added you to Project #{project_user.project.name}/, email.encoded)
  end

  test "comment by mail email" do
    comment = comments(:one)
    object = comment.class_name.constantize.find_by_id(comment.class_id)
    valid = users(:valid)

    email = UserMailer.comment_by_mail(comment, object, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{comment.user.name} Commented on #{object.class.name} #{object.name}", email.subject
    assert_match(/#{comment.user.name} made the following comment on #{object.class.name} #{object.name} located at #{SITE_URL}\/#{object.class.name.downcase.pluralize}\/#{object.id}\./, email.encoded)
  end

  test "sticky by mail email" do
    sticky = stickies(:one)
    valid = users(:valid)

    email = UserMailer.sticky_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{sticky.user.name} Added a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} added the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky by mail email with ics attachment" do
    sticky = stickies(:due_at_ics)
    valid = users(:valid)

    email = UserMailer.sticky_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert email.has_attachments?
    assert_equal 'event.ics', email.attachments.first.filename
    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{sticky.user.name} Added a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} added the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky completion by mail email" do
    sticky = stickies(:assigned_to_user)
    valid = users(:valid)

    email = UserMailer.sticky_completion_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{sticky.user.name} Completed a Sticky on Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} completed the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} on Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky due at changed by mail email" do
    sticky = stickies(:due_at_ics)
    valid = users(:valid)

    email = UserMailer.sticky_due_at_changed_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert email.has_attachments?
    assert_equal 'event.ics', email.attachments.first.filename
    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] Sticky #{sticky.name} Due Time Changed on Project #{sticky.project.name}", email.subject
    assert_match(/Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} on Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id} has an updated due time\./, email.encoded)
  end

  test "daily stickies due email" do
    valid = users(:valid)

    email = UserMailer.daily_stickies_due(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    due_today = "#{valid.all_stickies_due_today.size} " + (valid.all_stickies_due_today.size == 1 ? 'Sticky' : 'Stickies') + " Due Today"
    past_due = "#{valid.all_stickies_past_due.size} " + (valid.all_stickies_past_due.size == 1 ? 'Sticky' : 'Stickies') + " Past Due"
    due_upcoming = "#{valid.all_stickies_due_upcoming.size} " + (valid.all_stickies_due_upcoming.size == 1 ? 'Sticky' : 'Stickies') + " Upcoming"
    due_today = nil if valid.all_stickies_due_today.size == 0
    past_due = nil if valid.all_stickies_past_due.size == 0
    due_upcoming = nil if valid.all_stickies_due_upcoming.size == 0

    assert email.has_attachments?
    assert_equal 'event.ics', email.attachments.first.filename

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{[due_today, past_due, due_upcoming].compact.join(' and ')}", email.subject
    assert_match(/View stickies on a calendar here: #{"#{SITE_URL}/stickies/calendar"}/, email.encoded)
  end

  test "group by mail email" do
    group = groups(:one)
    valid = users(:valid)

    email = UserMailer.group_by_mail(group, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME}] #{group.user.name} Added a Group of Stickies to Project #{group.template.project.name}", email.subject
    assert_match(/#{group.user.name} added Group #{group.name} #{SITE_URL}\/groups\/#{group.id} with #{group.stickies.size} #{group.stickies.size == 1 ? 'Sticky' : 'Stickies'}#{" from Template #{group.template.name}" if group.template}\./, email.encoded)
  end

end
