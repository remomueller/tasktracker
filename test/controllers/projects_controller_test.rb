require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should show bulk reassign" do
    get :bulk, id: @project
    assert_not_nil assigns(:project)
    assert_template 'bulk'
    assert_response :success
  end

  test "should not show bulk reassign to viewers of project" do
    get :bulk, id: projects(:three)
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should reassign incomplete tasks" do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: false).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: false).count) do
        post :reassign, id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'not_completed'
      end
    end

    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test "should reassign complete tasks" do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: true).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: true).count) do
        post :reassign, id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'completed'
      end
    end

    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test "should reassign all tasks" do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id).count) do
        post :reassign, id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'all'
      end
    end

    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test "should reassign tasks based on tags" do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -2) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", 2) do
        post :reassign, id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'all', tag_id: tags(:beta).id
      end
    end
  end

  test "should reassign unassigned tasks to a user" do
    assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: nil).count", -10) do
      assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: #{users(:admin).id}).count", 10) do
        post :reassign, id: @project, from_user_id: nil, to_user_id: users(:admin).id, sticky_status: 'all'
      end
    end
  end

  test "should reassign assigned tasks to unassigned" do
    assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: #{users(:valid).id}).count", -7) do
      assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: nil).count", 7) do
        post :reassign, id: @project, from_user_id: users(:valid).id, to_user_id: nil, sticky_status: 'all'
      end
    end
  end

  test "should not reassign tasks as project viewers" do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", 0) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", 0) do
        post :reassign, id: projects(:three), from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'not_completed'
      end
    end

    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should set project color" do
    post :colorpicker, id: @project, color: '#aabbcc', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_not_nil assigns(:project)
    assert_equal '#aabbcc', users(:valid).colors["project_#{@project.to_param}"]
    assert_response :success
  end

  test "should not set project color" do
    post :colorpicker, id: -1, color: '#aabbcc', format: 'js'
    assert_nil assigns(:project)
    assert_response :success
  end

  test "should remove hidden attribute for project" do
    post :visible, id: projects(:hidden), visible: '1', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_not_nil assigns(:project)
    assert_equal false, users(:valid).hidden_project_ids.include?(assigns(:project).id)
    assert_response :success
  end

  test "should set hidden attribute for project" do
    post :visible, id: @project, visible: '0', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_not_nil assigns(:project)
    assert_equal true, users(:valid).hidden_project_ids.include?(assigns(:project).id)
    assert_response :success
  end

  test "should not set hidden attribute for invalid project" do
    post :visible, id: -1, visible: '0', format: 'js'
    assert_nil assigns(:project)
    assert_response :success
  end

  test "should get selection" do
    post :selection, sticky: { project_id: projects(:one).to_param }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:project_id)
    assert_template 'selection'
  end

  test "should not get selection without valid project id" do
    post :selection, sticky: { project_id: -1 }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:project)
    assert_nil assigns(:project_id)
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:projects)
    assert_template 'index'
  end

  test "should get index for api user using service account" do
    login(users(:service_account))
    get :index, api_token: 'screen_token', screen_token: users(:valid).screen_token, format: 'json'
    assert_not_nil assigns(:projects)

    projects = JSON.parse(@response.body)
    assert projects.first.keys.include?('id')
    assert projects.first.keys.include?('name')
    assert projects.first.keys.include?('color')
    assert projects.first.keys.include?('favorited')
    assert projects.first.keys.include?('tags')

    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: { name: 'New Project', description: '' }
    end
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).user_id.to_s, users(:valid).to_param
    assert_redirected_to project_path(assigns(:project))
  end

  test "should create project from popup" do
    assert_difference('Project.count') do
      post :create, project: { name: 'New Project', description: '' }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).user_id.to_s, users(:valid).to_param
    assert_not_nil assigns(:sticky)
    assert_template 'stickies/new'
  end

  test "should create project as json" do
    assert_difference('Project.count') do
      post :create, project: { name: "New Project", description: '' }, format: 'json'
    end

    project = JSON.parse(@response.body)
    assert_equal assigns(:project).id, project['id']
    assert_equal assigns(:project).name, project['name']
    assert_equal assigns(:project).description, project['description']
    assert_equal assigns(:project).user_id, project['user_id']
    assert_equal assigns(:project).project_link, project['project_link']
    assert_equal assigns(:project).color(users(:valid)), project['color']
    assert_equal false, project['favorited']
    assert_equal Array, project['tags'].class

    assert_response :success
  end

  test "should not create project with blank name" do
    assert_difference('Project.count', 0) do
      post :create, project: { name: "", description: '' }
    end

    assert_not_nil assigns(:project)
    assert_template 'new'
  end

  test "should show project" do
    get :show, id: @project
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should show ongoing project" do
    get :show, id: projects(:ongoing)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not show project without valid id" do
    get :show, id: -1
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    put :update, id: @project, project: { name: "Completed Project", description: 'Updated Description' }
    assert_redirected_to project_path(assigns(:project))
  end

  test "should update project as json" do
    put :update, id: @project, project: { name: "Completed Project", description: 'Updated Description' }, format: 'json'

    project = JSON.parse(@response.body)
    assert_equal assigns(:project).id, project['id']
    assert_equal 'Completed Project', project['name']
    assert_equal 'Updated Description', project['description']

    assert_response :success
  end

  test "should not update project with blank name" do
    put :update, id: @project, project: { name: "", description: 'Updated Description' }
    assert_not_nil assigns(:project)
    assert_template 'edit'
  end

  test "should not update project with invalid id" do
    put :update, id: -1, project: { name: "Completed Project", description: 'Updated Description' }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should destroy project" do
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end

  test "should not destroy project with invalid id" do
    assert_difference('Project.current.count', 0) do
      delete :destroy, id: -1
    end
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should create project favorite" do
    assert_difference('ProjectFavorite.where(favorite: true).count') do
      post :favorite, id: projects(:one), favorite: '1', format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'favorite'
  end

  test "should not create project favorite without valid id" do
    assert_difference('ProjectFavorite.where(favorite: true).count', 0) do
      post :favorite, id: -1, favorite: '1', format: 'js'
    end

    assert_nil assigns(:project)
    assert_response :success
  end

  test "should remove project favorite" do
    assert_difference('ProjectFavorite.where(favorite: false).count') do
      post :favorite, id: projects(:two), favorite: '0', format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'favorite'
  end
end
