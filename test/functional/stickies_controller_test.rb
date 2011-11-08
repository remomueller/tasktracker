require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sticky = stickies(:one)
  end

  test "should get search" do
    get :search, :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:frame)
    assert_not_nil assigns(:stickies)
    assert_template 'projects/show'
    assert_response :success
  end

  test "should not get search without valid project id" do
    get :search, :project_id => -1, :frame_id => frames(:one).to_param
    assert_nil assigns(:project)
    assert_nil assigns(:frame)
    assert_nil assigns(:stickies)
    assert_redirected_to root_path
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
      post :create, :sticky => {:description => "Sticky Description", :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param, :status => 'ongoing', :start_date => "08/15/2011", :end_date => "" }
    end

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should not create sticky with blank description" do
    assert_difference('Sticky.count', 0) do
      post :create, :sticky => {:description => "", :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param, :status => 'ongoing', :start_date => "08/15/2011", :end_date => "" }
    end

    assert_not_nil assigns(:sticky)
    assert_template 'new'
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
    put :update, :id => @sticky.to_param, :sticky => {:description => "Sticky Description Update", :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param, :status => 'completed', :start_date => "08/15/2011", :end_date => "08/16/2011" }
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should not update sticky with blank description" do
    put :update, :id => @sticky.to_param, :sticky => {:description => "", :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param, :status => 'completed', :start_date => "08/15/2011", :end_date => "08/16/2011" }
    assert_not_nil assigns(:sticky)
    assert_template 'edit'
  end

  test "should not update sticky with invalid id" do
    put :update, :id => -1, :sticky => {:description => "Sticky Description Update", :project_id => projects(:one).to_param, :frame_id => frames(:one).to_param, :status => 'completed', :start_date => "08/15/2011", :end_date => "08/16/2011" }
    assert_nil assigns(:sticky)
    assert_redirected_to root_path
  end

  test "should destroy sticky" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, :id => @sticky.to_param
    end

    assert_redirected_to stickies_path
  end
  
  test "should not destroy sticky without valid id" do
    assert_difference('Sticky.current.count', 0) do
      delete :destroy, :id => -1
    end
    
    assert_nil assigns(:sticky)
    assert_redirected_to root_path
  end
end
