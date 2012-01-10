require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  test "should only send sticky creation email to users with email activated" do
    assert_equal true, projects(:one).users_to_email(:sticky_creation).include?(users(:valid))
    assert_equal false, projects(:one).users_to_email(:sticky_creation).include?(users(:send_no_email))
    assert_equal false, projects(:one).users_to_email(:sticky_creation).include?(users(:send_no_email_for_project_one))
    assert_equal false, projects(:one).users_to_email(:sticky_creation).include?(users(:send_no_email_for_sticky_creation))
    assert_equal false, projects(:one).users_to_email(:sticky_creation).include?(users(:send_no_email_for_project_one_sticky_creation))
    assert_equal false, projects(:one).users_to_email(:sticky_creation).include?(users(:pending))
  end
  
  test "should only send sticky completion email to users with email activated" do
    assert_equal true, projects(:one).users_to_email(:sticky_completion).include?(users(:valid))
    assert_equal false, projects(:one).users_to_email(:sticky_completion).include?(users(:send_no_email))
    assert_equal false, projects(:one).users_to_email(:sticky_completion).include?(users(:send_no_email_for_project_one))
    assert_equal false, projects(:one).users_to_email(:sticky_completion).include?(users(:send_no_email_for_sticky_completion))
    assert_equal false, projects(:one).users_to_email(:sticky_completion).include?(users(:send_no_email_for_project_one_sticky_completion))
    assert_equal false, projects(:one).users_to_email(:sticky_completion).include?(users(:pending))    
  end

end
