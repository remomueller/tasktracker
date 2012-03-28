require 'test_helper'

SimpleCov.command_name "test:units"

class UserTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end

  test "should apply omniauth" do
    assert_not_nil users(:valid).apply_omniauth({ 'info' => {'email' => 'Email', 'first_name' => 'FirstName', 'last_name' => 'LastName' } })
  end

  test "should allow send_email for email_on?" do
    assert_equal true, users(:valid).email_on?(:send_email)
  end

  test "should not allow send_email for email_on?" do
    assert_equal false, users(:two).email_on?(:send_email)
  end

  test "should not allow the same api_token to be assigned to two users" do
    t = Time.now
    assert_equal '', users(:valid).generate_api_token!('screen_token', t)
    assert_equal 'Error - Please try regenerating', users(:two).generate_api_token!('screen_token', t)
  end
end
