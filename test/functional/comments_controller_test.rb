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

  test "should not get new" do
    get :new
    assert_redirected_to root_path
  end

  test "should create comment for an object in table format" do
    assert_difference('Comment.count') do
      post :add_comment_table, :class_name => @comment.class_name, :class_id => @comment.class_id, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assert_not_nil assigns(:object)
    assert_template 'add_comment_table'
  end

  test "should not add_comment_table without valid id" do
    assert_difference('Comment.count', 0) do
      post :add_comment_table, :class_name => @comment.class_name, :class_id => -1, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assert_nil assigns(:object)
    assert_response :success
  end

  test "should create comment for an object" do
    assert_difference('Comment.count') do
      post :add_comment, :class_name => @comment.class_name, :class_id => @comment.class_id, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assert_not_nil assigns(:object)
    assert_template 'add_comment'
  end

  test "should not add_comment without valid id" do
    assert_difference('Comment.count', 0) do
      post :add_comment, :class_name => @comment.class_name, :class_id => -1, :comment => "This is a comment.", :position => "1", :format => 'js'
    end
    
    assert_nil assigns(:object)
    assert_response :success
  end

  test "should search comments" do
    get :search, :class_name => @comment.class_name, :class_id => @comment.class_id, :format => 'js'
    
    assert_not_nil assigns(:object)
    assert_not_nil assigns(:comments)
    assert_template 'search'
  end

  test "should not search comments without valid id" do
    get :search, :class_name => @comment.class_name, :class_id => -1, :format => 'js'
    
    assert_nil assigns(:object)
    assert_nil assigns(:comments)
    assert_response :success
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

  test "should not update comment with blank description" do
    put :update, :id => @comment.to_param, :comment => {class_name: @comment.class_name, class_id: @comment.class_id, description: ''}
    assert_not_nil assigns(:comment)
    assert_template 'edit'
  end

  test "should not update comment without valid id" do
    put :update, :id => -1, :comment => @comment.attributes
    assert_nil assigns(:comment)
    assert_redirected_to root_path
  end

  test "should destroy comment" do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, :id => @comment.to_param
    end

    assert_redirected_to comments_path
  end
  
  test "should not destroy comment with invalid id" do
    assert_difference('Comment.current.count', 0) do
      delete :destroy, :id => -1
    end

    assert_redirected_to root_path
  end
  
  test "should show how to move comment" do
    get :move, :id => @comment.to_param
    assert_not_nil assigns(:comment)
    assert_template 'move'
    assert_response :success
  end
  
  test "should move comment to sticky" do
    post :move_update, :id => @comment.to_param, :class_name => comments(:two).class_name, :class_id => comments(:two).class_id
    assert_not_nil assigns(:comment)
    assert_not_nil assigns(:object)
    assert_equal comments(:two).class_name, assigns(:comment).class_name
    assert_equal comments(:two).class_id, assigns(:comment).class_id
    assert_redirected_to assigns(:object)
  end
  
  test "should not move comment with invalid id to sticky" do
    post :move_update, :id => -1, :class_name => comments(:two).class_name, :class_id => comments(:two).class_id
    assert_nil assigns(:comment)
    assert_redirected_to root_path
  end
  
  test "should not move comment to sticky with invalid id" do
    post :move_update, :id => @comment.to_param, :class_name => comments(:two).class_name, :class_id => -1
    assert_nil assigns(:object)
    assert_redirected_to root_path
  end
  
  test "should select object class and id for comment" do
    post :object_select, :id => @comment.to_param, :class_name => @comment.class_name, :format => 'js'
    assert_not_nil assigns(:comment)
    assert_not_nil assigns(:objects)
    assert_template 'object_select'
  end
  
  test "should not select object class and id for comment without valid id" do
    post :object_select, :id => -1, :class_name => @comment.class_name, :format => 'js'
    assert_nil assigns(:comment)
    assert_not_nil assigns(:objects)
    assert_response :success
  end
end
