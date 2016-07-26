# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:controllers'

# Tests to make sure users can access account settings, and
# that admins can edit and update existing users.
class UsersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:valid)
    @regular_user = users(:valid)
  end

  def user_params
    {
      first_name: 'New First Name',
      last_name: 'New Last Name',
      email: 'new_email@example.com',
      emails_enabled: '1',
      system_admin: '0'
    }
  end

  test 'should get index' do
    login(@admin)
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test 'should get index for autocomplete' do
    login(@regular_user)
    get :index, format: 'json'
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test 'should not get index for non-system admin' do
    login(@regular_user)
    get :index
    assert_nil assigns(:users)
    assert_equal 'You do not have sufficient privileges to access that page.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should show user' do
    login(@admin)
    get :show, params: { id: @user }
    assert_response :success
  end

  test 'should show associated user' do
    login(@regular_user)
    get :show, params: { id: users(:associated) }
    assert_not_nil assigns(:user)
    assert_response :success
  end

  test 'should get edit' do
    login(@admin)
    get :edit, params: { id: @user }
    assert_response :success
  end

  test 'should update user' do
    login(@admin)
    patch :update, params: { id: @user, user: user_params }
    assert_not_nil assigns(:user)
    assert_equal 'New First Name', assigns(:user).first_name
    assert_equal 'New Last Name', assigns(:user).last_name
    assert_equal 'new_email@example.com', assigns(:user).email
    assert_equal true, assigns(:user).emails_enabled
    assert_equal false, assigns(:user).system_admin
    assert_redirected_to user_path(assigns(:user))
  end

  test 'should not update user with blank name' do
    login(@admin)
    patch :update, params: { id: @user, user: user_params.merge(first_name: '', last_name: '') }
    assert_not_nil assigns(:user)
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update user with invalid id' do
    login(@admin)
    patch :update, params: { id: -1, user: user_params }
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test 'should destroy user' do
    login(@admin)
    assert_difference('User.current.count', -1) do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to users_path
  end
end
