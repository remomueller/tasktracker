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
    assert_equal "#{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end

  test "status activated email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test "user added to project email" do
    project_user = project_users(:one)

    email = UserMailer.user_added_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.user.email], email.to
    assert_equal "#{project_user.creator.name} Allows You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} has added you to Project #{project_user.project.name}/, email.encoded)
  end

  test "user invited to project email" do
    project_user = project_users(:invited)

    email = UserMailer.invite_user_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.invite_email], email.to
    assert_equal "#{project_user.creator.name} Invites You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} has invited you to Project #{project_user.project.name}/, email.encoded)
  end

  test "comment by mail email" do
    comment = comments(:two)
    sticky = comment.sticky
    valid = users(:valid)

    email = UserMailer.comment_by_mail(comment, sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{comment.user.name} Commented on Sticky #{sticky.name}", email.subject
    assert_match(/#{comment.user.name} COMMENTED on Sticky #{sticky.name} located at #{SITE_URL}\/stickies\/#{sticky.id}\./, email.encoded)
  end

  test "sticky by mail email" do
    sticky = stickies(:one)
    valid = users(:valid)

    email = UserMailer.sticky_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{sticky.user.name} Added a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} added Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky by mail email with ics attachment" do
    sticky = stickies(:due_at_ics)
    valid = users(:valid)

    email = UserMailer.sticky_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert email.has_attachments?
    assert_equal 'event.ics', email.attachments.first.filename
    assert_equal [valid.email], email.to
    assert_equal "#{sticky.user.name} Added a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} added Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky completion by mail email" do
    sticky = stickies(:assigned_to_user)
    valid = users(:valid)
    sender = users(:valid)

    email = UserMailer.sticky_completion_by_mail(sticky, sender, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{sender.name} Completed a Sticky on Project #{sticky.project.name}", email.subject
    assert_match(/#{sender.name} completed the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} on Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "stickies completion by mail email" do
    stickies = Sticky.where(id: stickies(:assigned_to_user).id)
    valid = users(:valid)
    sender = users(:valid)

    email = UserMailer.stickies_completion_by_mail(stickies, sender, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{sender.name} Completed 1 Sticky", email.subject
    assert_match(/#{sender.name} completed the following 1 Sticky\./, email.encoded)
  end

  test "sticky due at changed by mail email" do
    sticky = stickies(:due_at_ics)
    valid = users(:valid)

    email = UserMailer.sticky_due_at_changed_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert email.has_attachments?
    assert_equal 'event.ics', email.attachments.first.filename
    assert_equal [valid.email], email.to
    assert_equal "Sticky #{sticky.name} Due Time Changed on Project #{sticky.project.name}", email.subject
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
    assert_equal "#{[due_today, past_due, due_upcoming].compact.join(' and ')}", email.subject
    assert_match(/View stickies on a calendar here: #{"#{SITE_URL}/stickies/calendar"}/, email.encoded)
  end

  test "group by mail email" do
    group = groups(:one)
    valid = users(:valid)

    email = UserMailer.group_by_mail(group, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{group.user.name} Added a Group of Stickies to Project #{group.template.project.name}", email.subject
    assert_match(/#{group.user.name} added Group #{group.name} #{SITE_URL}\/groups\/#{group.id} with #{group.stickies.size} #{group.stickies.size == 1 ? 'Sticky' : 'Stickies'}#{" from Template #{group.template.name}" if group.template}\./, email.encoded)
  end

  test "daily digest email" do
    valid = users(:valid)

    email = UserMailer.daily_digest(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}", email.subject
    assert_match(/Hello #{valid.first_name},/, email.encoded)
  end

end
