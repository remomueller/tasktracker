require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "should only send task comments email to users with email activated" do
    # Note: Comments are only sent to the project creator and owner and others who have commented on the task.
    assert_equal true, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:valid))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_one))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_sticky_comments))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_one_sticky_comments))
  end

end
