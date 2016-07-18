# frozen_string_literal: true

require 'test_helper'

# Tests that assure that search works correctly.
class ApplicationControllerTest < ActionController::TestCase
  test 'should get search' do
    login(users(:valid))
    get :search, search: ''
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_response :success
  end

  test 'should get search and redirect' do
    login(users(:valid))
    get :search, search: "Ongoing Valid's Project"
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_equal 1, assigns(:objects).size
    assert_redirected_to assigns(:objects).first
  end

  test 'should get search and show tasks' do
    login(users(:valid))
    get :search, search: 'No Tasks Match This'
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_equal 0, assigns(:objects).size
    assert_redirected_to tasks_path(search: 'No Tasks Match This')
  end

  test 'should get search typeahead' do
    login(users(:valid))
    get :search, search: 'abc', format: 'json'
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)
    assert_response :success
  end
end
