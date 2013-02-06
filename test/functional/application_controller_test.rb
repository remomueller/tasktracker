require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    # Nothing
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get acceptable use policy" do
    get :use
    assert_response :success
  end

  test "should get search" do
    login(users(:valid))
    get :search, q: ''

    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)

    assert_response :success
  end

  test "should get search and redirect" do
    login(users(:valid))
    get :search, q: "Ongoing Valid's Project"

    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)

    assert_equal 1, assigns(:objects).size

    assert_redirected_to assigns(:objects).first
  end

  test "should get search typeahead" do
    login(users(:valid))
    get :search, q: 'abc', format: 'json'

    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:objects)

    assert_response :success
  end

end
