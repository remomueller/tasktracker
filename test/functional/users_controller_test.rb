require 'test_helper'

SimpleCov.command_name "test:functionals"

class UsersControllerTest < ActionController::TestCase
  setup do
    @current_user = login(users(:admin))
    @user = users(:valid)
  end

  test "should get overall_graph" do
    get :overall_graph

    assert_not_nil assigns(:stickies)
    assert_not_nil assigns(:comments)
    assert_not_nil assigns(:users_hash)
    assert_not_nil assigns(:users_comment_hash)

    assert assigns(:stickies).kind_of?(Array)
    assert assigns(:comments).kind_of?(Array)
    assert assigns(:users_hash).kind_of?(Hash)
    assert assigns(:users_comment_hash).kind_of?(Hash)

    assert_template 'overall_graph'
    assert_response :success
  end

  test "should get overall_graph with javascript" do
    get :overall_graph, year: '2011', format: 'js'

    assert_not_nil assigns(:stickies)
    assert_not_nil assigns(:comments)
    assert_not_nil assigns(:users_hash)
    assert_not_nil assigns(:users_comment_hash)

    assert assigns(:stickies).kind_of?(Array)
    assert assigns(:comments).kind_of?(Array)
    assert assigns(:users_hash).kind_of?(Hash)
    assert assigns(:users_comment_hash).kind_of?(Hash)

    assert_template 'overall_graph'
    assert_response :success
  end

  test "should get graph" do
    get :graph, id: users(:valid).to_param

    assert_not_nil assigns(:user)
    assert_not_nil assigns(:stickies)
    assert_not_nil assigns(:planned)
    assert_not_nil assigns(:completed)
    assert_not_nil assigns(:other_projects_hash)
    assert_not_nil assigns(:favorite_projects_hash)

    assert assigns(:stickies).kind_of?(Array)
    assert assigns(:planned).kind_of?(Array)
    assert assigns(:completed).kind_of?(Array)
    assert assigns(:other_projects_hash).kind_of?(Hash)
    assert assigns(:favorite_projects_hash).kind_of?(Hash)

    assert_template 'graph'
    assert_response :success
  end

  test "should get graph with javascript" do
    get :graph, id: users(:valid).to_param, year: '2011', format: 'js'

    assert_not_nil assigns(:user)
    assert_not_nil assigns(:stickies)
    assert_not_nil assigns(:planned)
    assert_not_nil assigns(:completed)
    assert_not_nil assigns(:other_projects_hash)
    assert_not_nil assigns(:favorite_projects_hash)

    assert assigns(:stickies).kind_of?(Array)
    assert assigns(:planned).kind_of?(Array)
    assert assigns(:completed).kind_of?(Array)
    assert assigns(:other_projects_hash).kind_of?(Hash)
    assert assigns(:favorite_projects_hash).kind_of?(Hash)

    assert_template 'graph'
    assert_response :success
  end

  test "should not get graph without valid user id" do
    get :graph, id: -1

    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should update settings and enable email" do
    post :update_settings, id: users(:admin).to_param, email: {send_email: '1'}
    users(:admin).reload # Needs reload to avoid stale object
    assert_equal true, users(:admin).email_on?(:send_email)
    assert_equal 'Email settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test "should update settings and disable email" do
    post :update_settings, id: users(:admin).to_param, email: {send_email: '0'}
    users(:admin).reload # Needs reload to avoid stale object
    assert_equal false, users(:admin).email_on?(:send_email)
    assert_equal 'Email settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test "should get index" do
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should get index with pagination" do
    get :index, format: 'js'
    assert_not_nil assigns(:users)
    assert_template 'index'
  end

  test "should get index for autocomplete" do
    login(users(:valid))
    get :index, format: 'json'
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(users(:valid))
    get :index
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should not get index with pagination for non-system admin" do
    login(users(:valid))
    get :index, format: 'js'
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  # test "should get new" do
  #   get :new
  #   assert_not_nil assigns(:user)
  #   assert_response :success
  # end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post :create, user: @user.attributes
  #   end
  #
  #   assert_redirected_to user_path(assigns(:user))
  # end

  test "should show user" do
    get :show, id: @user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user.to_param, user: @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    put :update, id: @user.to_param, user: {first_name: '', last_name: ''}
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test "should not update user with invalid id" do
    put :update, id: -1, user: @user.attributes
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should destroy user" do
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user.to_param
    end

    assert_redirected_to users_path
  end
end
