require 'test_helper'

class ProjectUsersControllerTest < ActionController::TestCase
  setup do
    @project_user = project_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_user" do
    assert_difference('ProjectUser.count') do
      post :create, :project_user => @project_user.attributes
    end

    assert_redirected_to project_user_path(assigns(:project_user))
  end

  test "should show project_user" do
    get :show, :id => @project_user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project_user.to_param
    assert_response :success
  end

  test "should update project_user" do
    put :update, :id => @project_user.to_param, :project_user => @project_user.attributes
    assert_redirected_to project_user_path(assigns(:project_user))
  end

  test "should destroy project_user" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, :id => @project_user.to_param
    end

    assert_redirected_to project_users_path
  end
end
