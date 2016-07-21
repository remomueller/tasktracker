# frozen_string_literal: true

require 'test_helper'

# Assure that groups can be created and updated.
class GroupsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @group = groups(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test 'should get new' do
    xhr :get, :new, format: 'js'
    assert_nil assigns(:group)
    assert_template 'new'
    assert_response :success
  end

  test 'should get new with project selected' do
    xhr :get, :new, project_id: projects(:one), format: 'js'
    assert_not_nil assigns(:group)
    assert_template 'new'
    assert_response :success
  end

  test 'should create group and generate stickies' do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:one), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:one).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should create group and generate tasks and create a new board for the group' do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:one), board_id: boards(:one) }, create_new_board: '1', group_board_name: 'New Board'
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_not_nil assigns(:board)
    assert_equal 'New Board', assigns(:board).name
    assert_equal projects(:one), assigns(:board).project
    assert_equal [assigns(:board).id], assigns(:group).stickies.pluck(:board_id).uniq
    assert_equal templates(:one).items.size, assigns(:group).stickies.size
    assert_equal users(:valid), assigns(:group).user
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should create group and generate tasks and add tasks to holding pen' do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:one), board_id: boards(:one) }, create_new_board: '1', group_board_name: ''
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_nil assigns(:board)
    assert_equal [nil], assigns(:group).stickies.pluck(:board_id).uniq
    assert_equal templates(:one).items.size, assigns(:group).stickies.size
    assert_equal users(:valid), assigns(:group).user
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should create group and generate tasks with default tags' do
    assert_difference('Sticky.count', templates(:with_tag).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:with_tag), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:with_tag).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal ['alpha'], assigns(:group).stickies.first.tags.collect{|t| t.name}
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should create group of tasks with due_at time and duration' do
    assert_difference('Sticky.count', templates(:with_due_at).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:with_due_at), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:with_due_at).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal '9pm', assigns(:group).stickies.first.due_time
    assert_equal 45, assigns(:group).stickies.first.duration
    assert_equal 'minutes', assigns(:group).stickies.first.duration_units
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should create group of tasks avoid weekends' do
    assert_difference('Sticky.count', templates(:avoid_weekends).items.size) do
      assert_difference('Group.count') do
        post :create, project_id: projects(:one), group: { template_id: templates(:avoid_weekends), board_id: boards(:one), initial_due_date: '3/10/2012' }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:avoid_weekends).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal Date.parse('2012-03-09'), assigns(:group).stickies.order('due_date').first.due_date
    assert_equal Date.parse('2012-03-12'), assigns(:group).stickies.order('due_date').last.due_date
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should not create group and generate tasks for invalid template id' do
    assert_difference('Sticky.count', 0) do
      assert_difference('Group.count', 0) do
        post :create, project_id: projects(:one), group: { template_id: -1, board_id: boards(:one) }
      end
    end
    assert_nil assigns(:template)
    assert_not_nil assigns(:board)
    assert_redirected_to groups_path
  end

  test 'should show group' do
    get :show, id: @group
    assert_not_nil assigns(:group)
    assert_response :success
  end

  test 'should not show group with invalid id' do
    get :show, id: -1
    assert_nil assigns(:group)
    assert_redirected_to groups_path
  end

  test 'should get edit' do
    get :edit, id: @group
    assert_response :success
  end

  test 'should update group' do
    patch :update, id: @group, group: { description: 'Group Description Update' }
    assert_not_nil assigns(:group)
    assert_equal [@group.project_id], assigns(:group).stickies.collect{|s| s.project_id}.uniq
    assert_equal [boards(:one).to_param], assigns(:group).stickies.collect{|s| s.board_id.to_s}.uniq
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should not update group with invalid id' do
    patch :update, id: -1, group: { description: 'Group Description Update' }
    assert_nil assigns(:group)
    assert_redirected_to groups_path
  end

  test 'should destroy group and attached stickies' do
    assert_difference('Sticky.current.count', -1 * @group.stickies.size) do
      assert_difference('Group.current.count', -1) do
        delete :destroy, id: @group
      end
    end
    assert_equal 0, assigns(:group).stickies.size
    assert_redirected_to groups_path
  end

  test 'should not destroy with invalid id' do
    assert_difference('Sticky.current.count', 0) do
      assert_difference('Group.current.count', 0) do
        delete :destroy, id: -1
      end
    end
    assert_nil assigns(:group)
    assert_redirected_to groups_path
  end
end
