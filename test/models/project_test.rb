# frozen_string_literal: true

require 'test_helper'

# Test project methods.
class ProjectTest < ActiveSupport::TestCase
  test 'should only send emails to users with email activated' do
    assert_equal true, projects(:one).users_to_email.include?(users(:valid))
    assert_equal false, projects(:one).users_to_email.include?(users(:send_no_email))
    assert_equal false, projects(:one).users_to_email.include?(users(:send_no_email_for_project_one))
  end

  test 'viewer on project should see project' do
    assert_equal true, projects(:one).viewable_by?(users(:associated))
  end

  test 'non- viewer/editor should not see project' do
    assert_equal false, projects(:one).viewable_by?(users(:two))
  end
end
