require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @comment = comments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should create comment for a sticky" do
    assert_difference('Comment.count') do
      post :create, sticky_id: @comment.sticky_id, comment: { description: "This is a comment." }, position: "1", format: 'js'
    end

    assert_not_nil assigns(:sticky)
    assert_template 'create'
  end

  test "should create comment for a sticky and send email to the sticky owner" do
    login(users(:admin))
    assert_difference('Comment.count') do
      post :create, sticky_id: @comment.sticky_id, comment: { description: "This is a comment." }, position: "1", format: 'js'
    end

    assert_not_nil assigns(:sticky)
    assert_template 'create'
  end

  test "should not create comment without valid id" do
    assert_difference('Comment.count', 0) do
      post :create, sticky_id: -1, comment: { description: "This is a comment." }, position: "1", format: 'js'
    end

    assert_nil assigns(:sticky)
    assert_template 'create'
  end

  test "should search comments" do
    get :search, sticky_id: @comment.sticky_id, format: 'js'

    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:comments)
    assert_template 'search'
  end

  test "should not search comments without valid id" do
    get :search, sticky_id: -1, format: 'js'

    assert_nil assigns(:sticky)
    assert_nil assigns(:comments)
    assert_response :success
  end

  test "should show comment" do
    get :show, id: @comment
    assert_response :success
  end

  test "should show comment as json" do
    get :show, id: @comment, format: 'json'

    comment = JSON.parse(@response.body)
    assert_equal assigns(:comment).id, comment['id']
    assert_equal assigns(:comment).description, comment['description']
    assert_equal assigns(:comment).sticky_id, comment['sticky_id']
    assert_equal assigns(:comment).user_id, comment['user_id']

    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @comment
    assert_response :success
  end

  test "should update comment" do
    put :update, id: @comment, comment: @comment.attributes
    assert_redirected_to sticky_path(assigns(:comment).sticky)
  end

  test "should update comment as json" do
    put :update, id: @comment, comment: { description: 'Updated description' }, format: 'json'

    comment = JSON.parse(@response.body)
    assert_equal assigns(:comment).id, comment['id']
    assert_equal 'Updated description', comment['description']
    assert_equal assigns(:comment).sticky_id, comment['sticky_id']
    assert_equal assigns(:comment).user_id, comment['user_id']

    assert_response :success
  end

  test "should not update comment with blank description" do
    put :update, id: @comment, comment: { sticky_id: @comment.sticky_id, description: '' }
    assert_not_nil assigns(:comment)
    assert_template 'edit'
  end

  test "should not update comment without valid id" do
    put :update, id: -1, comment: @comment.attributes
    assert_nil assigns(:comment)
    assert_redirected_to comments_path
  end

  test "should destroy comment" do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, id: @comment
    end

    assert_redirected_to comments_path
  end

  test "should not destroy comment with invalid id" do
    assert_difference('Comment.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_redirected_to comments_path
  end
end
