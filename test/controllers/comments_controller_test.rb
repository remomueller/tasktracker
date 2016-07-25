# frozen_string_literal: true

require 'test_helper'

# Test to assure comments can be made on tasks.
class CommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @comment = comments(:two)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test 'should create comment for a sticky' do
    assert_difference('Comment.count') do
      post :create, params: {
        sticky_id: @comment.sticky_id, comment: { description: 'This is a comment.' }, position: '1'
      }, format: 'js'
    end
    assert_not_nil assigns(:sticky)
    assert_template 'create'
  end

  test 'should create comment for a task and send email to the task owner' do
    login(users(:admin))
    assert_difference('Comment.count') do
      post :create, params: {
        sticky_id: @comment.sticky_id, comment: { description: 'This is a comment.' }, position: '1'
      }, format: 'js'
    end
    assert_not_nil assigns(:sticky)
    assert_template 'create'
  end

  test 'should not create comment without valid id' do
    assert_difference('Comment.count', 0) do
      post :create, params: {
        sticky_id: -1, comment: { description: 'This is a comment.' }, position: '1'
      }, format: 'js'
    end
    assert_nil assigns(:sticky)
    assert_template 'create'
  end

  test 'should show comment' do
    get :show, params: { id: @comment }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @comment }
    assert_response :success
  end

  test 'should update comment' do
    patch :update, params: { id: @comment, comment: @comment.attributes }
    assert_redirected_to sticky_path(assigns(:comment).sticky)
  end

  test 'should not update comment with blank description' do
    patch :update, params: { id: @comment, comment: { sticky_id: @comment.sticky_id, description: '' } }
    assert_not_nil assigns(:comment)
    assert_template 'edit'
  end

  test 'should not update comment without valid id' do
    patch :update, params: { id: -1, comment: @comment.attributes }
    assert_nil assigns(:comment)
    assert_redirected_to comments_path
  end

  test 'should destroy comment' do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, params: { id: @comment }
    end
    assert_redirected_to comments_path
  end

  test 'should not destroy comment with invalid id' do
    assert_difference('Comment.current.count', 0) do
      delete :destroy, params: { id: -1 }
    end
    assert_redirected_to comments_path
  end
end
