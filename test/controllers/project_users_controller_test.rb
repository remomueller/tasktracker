# frozen_string_literal: true

require 'test_helper'

# Tests to assure users can be added to a project.
class ProjectUsersControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:valid)
    @project_user = project_users(:one)
    @pending_editor_invite = project_users(:pending_editor_invite)
    @accepted_viewer_invite = project_users(:accepted_viewer_invite)
  end

  test 'should resend project invitation' do
    login(@regular_user)
    post :resend, params: { id: @pending_editor_invite }, format: 'js'
    assert_not_nil assigns(:project_user)
    assert_not_nil assigns(:project)
    assert_template 'resend'
  end

  test 'should not resend project invitation with invalid id' do
    login(@regular_user)
    post :resend, params: { id: -1 }, format: 'js'
    assert_nil assigns(:project_user)
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should get invite for logged in user' do
    login(users(:two))
    get :invite, params: { invite_token: @pending_editor_invite.invite_token }
    assert_equal session[:invite_token], @pending_editor_invite.invite_token
    assert_redirected_to accept_project_users_path
  end

  test 'should get invite for public user' do
    get :invite, params: { invite_token: @pending_editor_invite.invite_token }
    assert_equal session[:invite_token], @pending_editor_invite.invite_token
    assert_redirected_to new_user_session_path
  end

  test 'should create project user' do
    login(@regular_user)
    assert_difference('ProjectUser.count') do
      post :create, params: {
        project_id: projects(:two).to_param,
        editor: '1',
        invite_email: users(:associated).name + " [#{users(:associated).email}]"
      }, format: 'js'
    end
    assert_not_nil assigns(:project_user)
    assert_template 'index'
  end

  test 'should create project user invitation' do
    login(@regular_user)
    assert_difference('ProjectUser.count') do
      post :create, params: {
        project_id: projects(:one).to_param,
        editor: '1',
        invite_email: 'invite@example.com'
      }, format: 'js'
    end
    assert_not_nil assigns(:project_user)
    assert_not_nil assigns(:project_user).invite_token
    assert_template 'index'
  end

  test 'should not create project user with invalid project id' do
    login(@regular_user)
    assert_difference('ProjectUser.count', 0) do
      post :create, params: {
        project_id: -1,
        editor: '1',
        invite_email: users(:two).name + " [#{users(:two).email}]"
      }, format: 'js'
    end

    assert_nil assigns(:project_user)
    assert_response :success
  end

  test 'should accept project user' do
    login(users(:two))
    session[:invite_token] = @pending_editor_invite.invite_token
    get :accept
    assert_not_nil assigns(:project_user)
    assert_equal users(:two), assigns(:project_user).user
    assert_equal(
      'You have been successfully been added to the project.',
      flash[:notice]
    )
    assert_redirected_to assigns(:project_user).project
  end

  test 'should accept existing project user' do
    login(@regular_user)
    session[:invite_token] = project_users(:accepted_viewer_invite).invite_token
    get :accept
    assert_not_nil assigns(:project_user)
    assert_equal users(:valid), assigns(:project_user).user
    assert_equal(
      "You have already been added to #{assigns(:project_user).project.name}.",
      flash[:notice]
    )
    assert_redirected_to assigns(:project_user).project
  end

  test 'should not accept invalid token for project user' do
    login(@regular_user)
    session[:invite_token] = 'imaninvalidtoken'
    get :accept
    assert_nil assigns(:project_user)
    assert_equal 'Invalid invitation token.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not accept project user if invite token is already claimed' do
    login(users(:two))
    session[:invite_token] = 'accepted_viewer_invite'
    get :accept
    assert_not_nil assigns(:project_user)
    assert_not_equal users(:two), assigns(:project_user).user
    assert_equal 'This invite has already been claimed.', flash[:alert]
    assert_redirected_to root_path
  end

  # test 'should show project_user' do
  #   get :show, params: { id: @project_user.to_param }
  #   assert_response :success
  # end
  #
  # test 'should get edit' do
  #   get :edit, params: { id: @project_user.to_param }
  #   assert_response :success
  # end
  #
  # test 'should update project_user' do
  #   patch :update, params: { id: @project_user.to_param, project_user: @project_user.attributes }
  #   assert_redirected_to project_user_path(assigns(:project_user))
  # end

  test 'should destroy project user' do
    login(@regular_user)
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, params: { id: @project_user.to_param }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test 'should allow viewer to remove self from project' do
    login(@regular_user)
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, params: { id: project_users(:five) }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test 'should destroy project user with invalid id' do
    login(@regular_user)
    assert_difference('ProjectUser.count', 0) do
      delete :destroy, params: { id: -1 }, format: 'js'
    end
    assert_nil assigns(:project)
    assert_response :success
  end
end
