require 'test_helper'

class FramesControllerTest < ActionController::TestCase
  setup do
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
      post :create, :frame => @frame.attributes
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
    put :update, :id => @frame.to_param, :frame => @frame.attributes
    assert_redirected_to frame_path(assigns(:frame))
  end

  test "should destroy frame" do
    assert_difference('Frame.count', -1) do
      delete :destroy, :id => @frame.to_param
    end

    assert_redirected_to frames_path
  end
end
