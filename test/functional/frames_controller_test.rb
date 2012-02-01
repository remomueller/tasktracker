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
      post :create, frame: { name: "Frame Name", project_id: projects(:one).to_param, description: "", start_date: "08/15/2011", end_date: "12/31/2011" }
    end

    assert_not_nil assigns(:frame)
    assert_equal assigns(:frame).user_id.to_s, users(:valid).to_param

    assert_redirected_to frame_path(assigns(:frame))
  end

  test "should not create frame with blank name" do
    assert_difference('Frame.count', 0) do
      post :create, frame: { name: "", project_id: projects(:one).to_param, description: "", start_date: "08/15/2011", end_date: "12/31/2011" }
    end

    assert_not_nil assigns(:frame)
    assert_template 'new'
  end

  test "should show frame" do
    get :show, id: @frame.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @frame.to_param
    assert_response :success
  end

  test "should update frame" do
    put :update, id: @frame.to_param, frame: { name: "Frame Name Update", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
    assert_redirected_to frame_path(assigns(:frame))
  end

  test "should not update frame with blank name" do
    put :update, id: @frame.to_param, frame: { name: "", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
    assert_not_nil assigns(:frame)
    assert_template 'edit'
  end

  test "should not update frame with invalid id" do
    put :update, id: -1, frame: { name: "Frame Name Update", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
    assert_nil assigns(:frame)
    assert_redirected_to root_path
  end

  test "should destroy frame and move attached stickies to project backlog" do
    assert_difference('Sticky.with_frame(0).count', @frame.stickies.size) do
      assert_difference('Sticky.current.count', 0) do
        assert_difference('Frame.current.count', -1) do
          delete :destroy, id: @frame.to_param
        end
      end
    end

    assert_equal 0, @frame.stickies.size
    assert_redirected_to frames_path
  end

  test "should not destroy with invalid id" do
    assert_difference('Frame.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:frame)
    assert_redirected_to root_path
  end
end
