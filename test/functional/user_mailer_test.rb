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
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end
  
  test "status activated email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test "user added to project email" do
    project_user = project_users(:one)

    email = UserMailer.user_added_to_project(project_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.user.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{project_user.project.user.name} Allows You to #{project_user.allow_editing? ? 'Edit' : 'View'} #{project_user.project.name}", email.subject
    assert_match(/#{project_user.project.user.name} has added you to Project #{project_user.project.name}/, email.encoded)
  end

  test "comment by mail email" do
    comment = comments(:one)
    object = comment.class_name.constantize.find_by_id(comment.class_id)
    valid = users(:valid)
    
    email = UserMailer.comment_by_mail(comment, object, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{comment.user.name} Commented on #{object.class.name} #{object.name}", email.subject
    assert_match(/#{comment.user.name} made the following comment on #{object.class.name} #{object.name} located at #{SITE_URL}\/#{object.class.name.downcase.pluralize}\/#{object.id}\./, email.encoded)
  end

  test "sticky by mail email" do
    sticky = stickies(:one)
    valid = users(:valid)
    
    email = UserMailer.sticky_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{sticky.user.name} Added a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} added the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} to Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

  test "sticky completion by mail email" do
    sticky = stickies(:assigned_to_user)
    valid = users(:valid)
    
    email = UserMailer.sticky_completion_by_mail(sticky, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "[#{DEFAULT_APP_NAME.downcase}] #{sticky.user.name} Completed a Sticky to Project #{sticky.project.name}", email.subject
    assert_match(/#{sticky.user.name} completed the following Sticky #{sticky.name} #{SITE_URL}\/stickies\/#{sticky.id} on Project #{sticky.project.name} #{SITE_URL}\/projects\/#{sticky.project.id}\./, email.encoded)
  end

end
