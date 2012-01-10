require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "should only send project comments email to users with email activated" do
    assert_equal true, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:valid))
    # Note: Comments are only sent to the project creator or others who have commented on the project.
    #       If this is changed to anyone on the project then the following to assertions should hold
    # assert_equal true, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email_for_sticky_comments))
    # assert_equal true, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email_for_project_one_sticky_comments))
    
    assert_equal false, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email))
    assert_equal false, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email_for_project_one))
    assert_equal false, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email_for_project_comments))
    assert_equal false, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:send_no_email_for_project_one_project_comments))
    assert_equal false, comments(:one).users_to_email(:project_comments, projects(:one).to_param, projects(:one)).include?(users(:pending))
  end

  test "should only send sticky comments email to users with email activated" do
    assert_equal true, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:valid))
    # Note: Comments are only sent to the project creator or others who have commented on the sticky.
    #       If this is changed to anyone on the project then the following to assertions should hold
    # assert_equal true, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_comments))
    # assert_equal true, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_one_project_comments))
    
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_one))    
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_sticky_comments))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:send_no_email_for_project_one_sticky_comments))
    assert_equal false, comments(:two).users_to_email(:sticky_comments, projects(:one).to_param, stickies(:one)).include?(users(:pending))
  end


end
