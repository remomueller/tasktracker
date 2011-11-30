require 'test_helper'

SimpleCov.command_name "test:units"

class UserTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end
  
  test "should apply omniauth" do
    assert_not_nil users(:valid).apply_omniauth({'user_info' => {'email' => 'Email', 'first_name' => 'FirstName', 'last_name' => 'LastName'}})
  end
end
