require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, :project => {:name => "New Project", :description => '', :status => 'ongoing', :start_date => "01/01/2011", :end_date => ''}
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    get :show, :id => @project.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project.to_param
    assert_response :success
  end

  test "should update project" do
    put :update, :id => @project.to_param, :project => {:name => "Completed Project", :description => 'Updated Description', :status => 'completed', :start_date => "01/01/2011", :end_date => '12/31/2011'}
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    assert_difference('Project.current.count', -1) do
      delete :destroy, :id => @project.to_param
    end

    assert_redirected_to projects_path
  end
  
  test "should create project favorite" do
    assert_difference('ProjectFavorite.where(:favorite => true).count') do
      post :favorite, :id => projects(:one).to_param, :favorite => '1', :format => 'js'
    end

    assigns(:project)
    assert_template 'favorite'
  end
  
  test "should remove project favorite" do
    assert_difference('ProjectFavorite.where(:favorite => false).count') do
      post :favorite, :id => projects(:two).to_param, :favorite => '0', :format => 'js'
    end
    
    assigns(:project)
    assert_template 'favorite'
  end
end
