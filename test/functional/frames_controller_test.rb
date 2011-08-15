require 'test_helper'

class FramesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @frame = frames(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:frames)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create frame" do
    assert_difference('Frame.count') do
      post :create, :frame => {:name => "Frame Name", :project_id => 1, :description => "", :start_date => "08/15/2011", :end_date => "12/31/2011" }
    end

    assert_redirected_to frame_path(assigns(:frame))
  end

  test "should show frame" do
    get :show, :id => @frame.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @frame.to_param
    assert_response :success
  end

  test "should update frame" do
    put :update, :id => @frame.to_param, :frame => {:name => "Frame Name Update", :project_id => 1, :description => "Updated Description", :start_date => "08/15/2011", :end_date => "01/31/2012" }
    assert_redirected_to frame_path(assigns(:frame))
  end

  test "should destroy frame" do
    assert_difference('Frame.current.count', -1) do
      delete :destroy, :id => @frame.to_param
    end

    assert_redirected_to frames_path
  end
end
