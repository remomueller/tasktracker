# frozen_string_literal: true

require 'test_helper'

class ProjectUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'should not generate duplicate invite token' do
    project_user = project_users(:one)
    project_user.generate_invite_token!('abc123')
    assert_nil project_user.invite_token
  end
end
