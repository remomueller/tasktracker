# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:models'

# Test user model methods.
class UserTest < ActiveSupport::TestCase
  test 'should get reverse name' do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end

  test 'should allow send_email for email_on?' do
    assert_equal true, users(:valid).emails_enabled?
  end

  test 'should not allow send_email for email_on?' do
    assert_equal false, users(:two).emails_enabled?
  end
end
