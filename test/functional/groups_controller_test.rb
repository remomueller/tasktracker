require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @group = groups(:one)
  end

  test "should get project selection" do
    post :project_selection, group: { project_id: projects(:one) }, format: 'js'
    assert_not_nil assigns(:group)
    assert_not_nil assigns(:project_id)
    assert_template 'project_selection'
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new, format: 'js'
    assert_template 'new_redesign'
    assert_not_nil assigns(:group)
    assert_response :success
  end

  test "should create group and generate stickies" do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:one), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:one).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_redirected_to group_path(assigns(:group))
  end

  test "should create group and generate stickies and create a new board for the group" do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:one), board_id: boards(:one) }, create_new_board: '1', group_board_name: 'New Board'
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

  test "should create group and generate stickies and add stickies to holding pen" do
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:one), board_id: boards(:one) }, create_new_board: '1', group_board_name: ''
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

  test "should create group and generate stickies for user through service account" do
    login(users(:service_account))
    assert_difference('Sticky.count', templates(:one).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:one), board_id: boards(:one), initial_due_date: '01/02/2013' }, api_token: 'screen_token', screen_token: users(:valid).screen_token, format: 'json'
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:one).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal assigns(:group).to_json, response.body
    assert_response :success
  end

  test "should create group and generate stickies with default tags" do
    assert_difference('Sticky.count', templates(:with_tag).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:with_tag), board_id: boards(:one) }
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

  test "should create group of stickies with due_at time and duration" do
    assert_difference('Sticky.count', templates(:with_due_at).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:with_due_at), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:with_due_at).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal '9:00 PM', assigns(:group).stickies.first.due_at_string
    assert_equal 45, assigns(:group).stickies.first.duration
    assert_equal 'minutes', assigns(:group).stickies.first.duration_units
    assert_redirected_to group_path(assigns(:group))
  end

  test "should create group of stickies avoid weekends" do
    assert_difference('Sticky.count', templates(:avoid_weekends).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:avoid_weekends), board_id: boards(:one), initial_due_date: "3/10/2012" }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:avoid_weekends).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal Time.local(2012, 3, 9, 0, 0, 0), assigns(:group).stickies.order('due_date').first.due_date
    assert_equal Time.local(2012, 3, 12, 0, 0, 0), assigns(:group).stickies.order('due_date').last.due_date
    assert_redirected_to group_path(assigns(:group))
  end

  test "should create group of stickies and set invalid due_at time and duration to default" do
    assert_difference('Sticky.count', templates(:with_due_at_invalid).items.size) do
      assert_difference('Group.count') do
        post :create, group: { project_id: projects(:one), template_id: templates(:with_due_at_invalid), board_id: boards(:one) }
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal templates(:with_due_at_invalid).items.size, assigns(:group).stickies.size
    assert_equal boards(:one), assigns(:board)
    assert_equal users(:valid), assigns(:group).user
    assert_equal '', assigns(:group).stickies.first.due_at_string
    assert_equal 0, assigns(:group).stickies.first.duration
    assert_equal 'hours', assigns(:group).stickies.first.duration_units
    assert_redirected_to group_path(assigns(:group))
  end

  test "should not create group and generate stickies for invalid template id" do
    assert_difference('Sticky.count', 0) do
      assert_difference('Group.count', 0) do
        post :create, group: { project_id: projects(:one), template_id: -1, board_id: boards(:one) }
      end
    end
    assert_nil assigns(:template)
    assert_not_nil assigns(:board)
    assert_redirected_to root_path
  end

  test "should show group" do
    get :show, id: @group
    assert_not_nil assigns(:group)
    assert_response :success
  end

  test "should show group with json" do
    get :show, id: @group, format: 'json'
    assert_not_nil assigns(:group)
    assert_response :success
  end

  test "should not show group with invalid id" do
    get :show, id: -1
    assert_nil assigns(:group)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @group
    assert_response :success
  end

  test "should update group" do
    put :update, id: @group, group: { description: "Group Description Update" }
    assert_not_nil assigns(:group)
    assert_equal [@group.project_id], assigns(:group).stickies.collect{|s| s.project_id}.uniq
    assert_equal [boards(:one).to_param], assigns(:group).stickies.collect{|s| s.board_id.to_s}.uniq
    assert_redirected_to group_path(assigns(:group))
  end

  test "should update group and move group and stickies to another project" do
    put :update, id: @group, group: { description: "Group Description Update", project_id: projects(:two) }
    assert_not_nil assigns(:group)
    assert_equal [projects(:two).to_param], assigns(:group).stickies.collect{|s| s.project_id.to_s}.uniq
    assert_equal [nil], assigns(:group).stickies.collect{|s| s.board_id}.uniq
    assert_redirected_to group_path(assigns(:group))
  end

  test "should not update group with blank project" do
    put :update, id: @group, group: { description: 'Group Description Update', project_id: nil }
    assert_not_nil assigns(:group)
    assert assigns(:group).errors.size > 0
    assert_equal ["can't be blank"], assigns(:group).errors[:project_id]
    assert_template 'edit'
  end

  test "should not update group with invalid id" do
    put :update, id: -1, group: { description: "Group Description Update" }
    assert_nil assigns(:group)
    assert_redirected_to root_path
  end

  test "should destroy group and attached stickies" do
    assert_difference('Sticky.current.count', -1 * @group.stickies.size) do
      assert_difference('Group.current.count', -1) do
        delete :destroy, id: @group
      end
    end

    assert_equal 0, assigns(:group).stickies.size
    assert_redirected_to groups_path
  end

  test "should not destroy with invalid id" do
    assert_difference('Sticky.current.count', 0) do
      assert_difference('Group.current.count', 0) do
        delete :destroy, id: -1
      end
    end

    assert_nil assigns(:group)
    assert_redirected_to groups_path
  end
end
