require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sticky = stickies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stickies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sticky" do
    assert_difference('Sticky.count') do
      post :create, :sticky => {:description => "Sticky Description", :project_id => 1, :frame_id => 1, :status => 'ongoing', :start_date => "08/15/2011", :end_date => "" }
    end

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should show sticky" do
    get :show, :id => @sticky.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sticky.to_param
    assert_response :success
  end

  test "should update sticky" do
    put :update, :id => @sticky.to_param, :sticky => {:description => "Sticky Description Update", :project_id => 1, :frame_id => 1, :status => 'completed', :start_date => "08/15/2011", :end_date => "08/16/2011" }
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should destroy sticky" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, :id => @sticky.to_param
    end

    assert_redirected_to stickies_path
  end
end
