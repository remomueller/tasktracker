require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @comment = comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should create comment for an object in table format" do
    assert_difference('Comment.count') do
      post :add_comment_table, :class_name => @comment.class_name, :class_id => @comment.class_id, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assigns(:comment)
    assert_template 'add_comment_table'
  end

  test "should create comment for an object" do
    assert_difference('Comment.count') do
      post :add_comment, :class_name => @comment.class_name, :class_id => @comment.class_id, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assigns(:comment)
    assert_template 'add_comment'
  end

  test "should show comment" do
    get :show, :id => @comment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @comment.to_param
    assert_response :success
  end

  test "should update comment" do
    put :update, :id => @comment.to_param, :comment => @comment.attributes
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "should destroy comment" do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, :id => @comment.to_param
    end

    assert_redirected_to comments_path
  end
end
