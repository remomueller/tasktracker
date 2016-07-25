# frozen_string_literal: true

require 'test_helper'

# Tests that assure that search works correctly.
class InternalControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:valid)
  end

  test 'should get search' do
    login(@regular_user)
    get :search, params: { search: '' }
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_response :success
  end

  test 'should get search and redirect' do
    login(@regular_user)
    get :search, params: { search: "Ongoing Valid's Project" }
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_equal 1, assigns(:objects).size
    assert_redirected_to assigns(:objects).first
  end

  test 'should get search and show tasks' do
    login(@regular_user)
    get :search, params: { search: 'No Tasks Match This' }
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_equal 0, assigns(:objects).size
    assert_redirected_to tasks_path(search: 'No Tasks Match This')
  end

  test 'should set task status to show all tasks' do
    login(@regular_user)
    post :update_task_status, params: { status: 'all' }
    @regular_user.reload
    assert_nil @regular_user.calendar_task_status
    assert_redirected_to month_path
  end

  test 'should set task status to show completed tasks' do
    login(@regular_user)
    post :update_task_status, params: { status: 'completed' }
    @regular_user.reload
    assert_equal true, @regular_user.calendar_task_status
    assert_redirected_to month_path
  end

  test 'should set task status to show open tasks' do
    login(@regular_user)
    post :update_task_status, params: { status: 'open' }
    @regular_user.reload
    assert_equal false, @regular_user.calendar_task_status
    assert_redirected_to month_path
  end
end
