# frozen_string_literal: true

require 'test_helper'

# Tests to assure project level tasks can be completed.
class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test 'should show bulk reassign' do
    get :bulk, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_template 'bulk'
    assert_response :success
  end

  test 'should not show bulk reassign to viewers of project' do
    get :bulk, params: { id: projects(:three) }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should reassign incomplete tasks' do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: false).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: false).count) do
        post :reassign, params: { id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'not_completed' }
      end
    end
    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test 'should reassign complete tasks' do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: true).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id, completed: true).count) do
        post :reassign, params: { id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'completed' }
      end
    end
    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test 'should reassign all tasks' do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -1 * Sticky.where(project_id: @project.id, owner_id: users(:valid).id).count) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", Sticky.where(project_id: @project.id, owner_id: users(:valid).id).count) do
        post :reassign, params: { id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'all' }
      end
    end

    assert_not_nil assigns(:project)
    assert_redirected_to assigns(:project)
  end

  test 'should reassign tasks based on tags' do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", -2) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", 2) do
        post :reassign, params: { id: @project, from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'all', tag_id: tags(:beta).id }
      end
    end
  end

  test 'should reassign unassigned tasks to a user' do
    assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: nil).count", -10) do
      assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: #{users(:admin).id}).count", 10) do
        post :reassign, params: { id: @project, from_user_id: nil, to_user_id: users(:admin).id, sticky_status: 'all' }
      end
    end
  end

  test 'should reassign assigned tasks to unassigned' do
    assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: #{users(:valid).id}).count", -7) do
      assert_difference("Sticky.where(project_id: #{projects(:one).id}, owner_id: nil).count", 7) do
        post :reassign, params: { id: @project, from_user_id: users(:valid).id, to_user_id: nil, sticky_status: 'all' }
      end
    end
  end

  test 'should not reassign tasks as project viewers' do
    assert_difference("Sticky.where(owner_id: #{users(:valid).id}).count", 0) do
      assert_difference("Sticky.where(owner_id: #{users(:admin).id}).count", 0) do
        post :reassign, params: { id: projects(:three), from_user_id: users(:valid).id, to_user_id: users(:admin).id, sticky_status: 'not_completed' }
      end
    end
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should get selection' do
    post :selection, params: { sticky: { project_id: projects(:one).to_param } }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:project)
    assert_template 'selection'
  end

  test 'should not get selection without valid project id' do
    post :selection, params: { sticky: { project_id: -1 } }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create project' do
    assert_difference('Project.count') do
      post :create, params: { project: { name: 'New Project', description: '' } }
    end
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).user_id.to_s, users(:valid).to_param
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should create project from popup' do
    assert_difference('Project.count') do
      post :create, params: { project: { name: 'New Project', description: '' }, format: 'js' }
    end
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).user_id.to_s, users(:valid).to_param
    assert_not_nil assigns(:sticky)
    assert_template 'stickies/new'
  end

  test 'should not create project with blank name' do
    assert_difference('Project.count', 0) do
      post :create, params: { project: { name: '', description: '' } }
    end
    assert_not_nil assigns(:project)
    assert_template 'new'
  end

  test 'should show project' do
    get :show, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show ongoing project' do
    get :show, params: { id: projects(:ongoing) }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not show project without valid id' do
    get :show, params: { id: -1 }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should get edit' do
    get :edit, params: { id: @project }
    assert_response :success
  end

  test 'should update project' do
    patch :update, params: { id: @project, project: { name: 'Completed Project', description: 'Updated Description' } }
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should not update project with blank name' do
    patch :update, params: { id: @project, project: { name: '', description: 'Updated Description' } }
    assert_not_nil assigns(:project)
    assert_template 'edit'
  end

  test 'should not update project with invalid id' do
    patch :update, params: { id: -1, project: { name: 'Completed Project', description: 'Updated Description' } }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should destroy project' do
    assert_difference('Project.current.count', -1) do
      delete :destroy, params: { id: @project }
    end
    assert_redirected_to projects_path
  end

  test 'should not destroy project with invalid id' do
    assert_difference('Project.current.count', 0) do
      delete :destroy, params: { id: -1 }
    end
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end
end
