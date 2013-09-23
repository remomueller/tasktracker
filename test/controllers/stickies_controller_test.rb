require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sticky = stickies(:one)
  end

  test "should get csv" do
    get :index, format: 'csv', status: ['completed', 'not completed']
    assert_not_nil assigns(:csv_string)
    assert_response :success
  end

  test "should get calendar month" do
    get :month
    assert_not_nil assigns(:anchor_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'month'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stickies)
  end

  test "should get index with all selected tags" do
    get :index, format: 'js', update_filters: '1', tag_filter: 'all', tag_names: [ 'alpha', 'beta' ], status: ['not completed', 'completed']

    # Should only return stickies(:tagged)
    assert_not_nil assigns(:stickies)
    assert_equal 1, assigns(:stickies).size
    assert_equal stickies(:tagged), assigns(:stickies).first

    assert_template 'index'
    assert_response :success
  end

  test "should get index with at least one selected tags" do
    get :index, format: 'js', update_filters: '1', tag_filter: 'any', tag_names: [ 'alpha', 'beta' ], status: ['not completed', 'completed']
    # Should return stickies(:tagged), stickies(:only_alpha), and stickies(:only_beta)
    assert_not_nil assigns(:stickies)
    assert_equal 3, assigns(:stickies).size
    assert_equal [stickies(:only_alpha), stickies(:only_beta), stickies(:tagged)], assigns(:stickies).order('stickies.description')

    assert_template 'index'
    assert_response :success
  end

  test "should get index for api user using service account" do
    login(users(:service_account))
    get :index, api_token: 'screen_token', screen_token: users(:valid).screen_token, tag_filter: 'any', tag_names: [ 'alpha', 'beta' ], status: ['not completed', 'completed'], format: 'json'
    assert_not_nil assigns(:stickies)
    assert_response :success
  end

  test "should get index with completed scope" do
    get :index, format: 'js', scope: 'completed', unassigned: '1'

    # Should only return stickies that are completed
    assert_not_nil assigns(:stickies)
    assert_equal [true], assigns(:stickies).collect{|s| s.completed}.uniq

    assert_template 'index'
    assert_response :success
  end

  test "should get index with past due scope" do
    get :index, format: 'js', scope: 'past_due', unassigned: '1'

    # Should only return stickies that are not completed
    assert_not_nil assigns(:stickies)
    assert_equal [false], assigns(:stickies).collect{|s| s.completed}.uniq

    assert_template 'index'
    assert_response :success
  end

  test "should get index with upcoming scope" do
    get :index, format: 'js', scope: 'upcoming', unassigned: '1'

    # Should only return stickies that are not completed
    assert_not_nil assigns(:stickies)
    assert_equal [false], assigns(:stickies).collect{|s| s.completed}.uniq

    assert_template 'index'
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky as json" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, format: 'json'
    end

    sticky = JSON.parse(@response.body)
    assert_equal assigns(:sticky).id, sticky['id']
    assert_equal assigns(:sticky).all_day, sticky['all_day']
    assert_equal assigns(:sticky).completed, sticky['completed']
    assert_equal assigns(:sticky).description, sticky['description']
    assert_equal assigns(:sticky).group_description, sticky['group_description']
    assert_not_nil sticky['due_date']
    assert_equal assigns(:sticky).user_id, sticky['user_id']
    assert_equal assigns(:sticky).duration, sticky['duration']
    assert_equal assigns(:sticky).duration_units, sticky['duration_units']
    assert_equal assigns(:sticky).board_id, sticky['board_id']
    assert_equal assigns(:sticky).group_id, sticky['group_id']
    assert_equal assigns(:sticky).owner_id, sticky['owner_id']
    assert_equal assigns(:sticky).project_id, sticky['project_id']
    assert_equal assigns(:sticky).sticky_link, sticky['sticky_link']
    assert_equal assigns(:sticky).repeat, sticky['repeat']
    assert_equal assigns(:sticky).repeat_amount, sticky['repeat_amount']
    assert_equal Array, sticky['tags'].class

    assert_response :success
  end

  test "should create sticky and create a new board for the sticky" do
    assert_difference('Sticky.count') do
      assert_difference('Board.count') do
        post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: 'New Board'
      end
    end

    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:board)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal assigns(:board).name, assigns(:sticky).board.name
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky and assign to existing board" do
    assert_difference('Sticky.count') do
      assert_difference('Board.count', 0) do
        post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, create_new_board: '0', sticky_board_name: 'New Board'
      end
    end

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:board)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky and set without a board" do
    assert_difference('Sticky.count') do
      assert_difference('Board.count', 0) do
        post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: ''
      end
    end

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:board)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_nil assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky and assign to existing board found by board name" do
    assert_difference('Sticky.count') do
      assert_difference('Board.count', 0) do
        post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: 'Board One'
      end
    end

    assert_not_nil assigns(:sticky)
    assert_not_nil boards(:one)
    assert_equal boards(:one), assigns(:board)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with all day due date" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011", due_at_string: '' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal true, assigns(:sticky).all_day?
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with due date and due at time" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "03/12/2012", due_at_string: '9pm', duration: '30', duration_units: 'minutes' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2012, 3, 12, 21, 0, 0), assigns(:sticky).due_date
    assert_equal false, assigns(:sticky).all_day?

    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with blank time and duration" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "03/12/2012", due_at_string: 'wrong time', duration: '0', duration_units: 'minutes' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2012, 3, 12, 0, 0, 0), assigns(:sticky).due_date
    assert_equal true, assigns(:sticky).all_day?

    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky from calendar" do
    assert_difference('Sticky.count') do
      post :create, from: 'month', sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }, format: 'js'
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_template 'create'
    assert_response :success
  end

  test "should create sticky and ignore invalid repeat amount when repeat is none" do
    assert_difference('Sticky.count') do
      post :create, from: 'month', sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', repeat: 'none', repeat_amount: '0' }, format: 'js'
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal "none", assigns(:sticky).repeat
    assert_equal 1, assigns(:sticky).repeat_amount
    assert_template 'create'
    assert_response :success
  end

  test "should create a planned sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create an ongoing sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create a completed sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create a sticky with a due time" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "12/10/2011", due_at_string: '9pm', duration: '30', duration_units: 'minutes' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_equal "9:00 PM", assigns(:sticky).due_at_string
    assert_equal "9:30 PM (30 minutes)", assigns(:sticky).due_at_end_string_with_duration

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should not create sticky with blank description" do
    assert_difference('Sticky.count', 0) do
      post :create, sticky: { description: "", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:description]
    assert_template 'new'
  end

  test "should not create sticky with blank project" do
    assert_difference('Sticky.count', 0) do
      post :create, sticky: { description: "Sticky Description", project_id: nil, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:project_id]
    assert_template 'new'
  end

  test "should show sticky" do
    get :show, id: @sticky
    assert_response :success
  end

  test "should show sticky with group description" do
    get :show, id: stickies(:grouped)
    assert_response :success
  end

  test "should not show sticky for user not on project" do
    login(users(:two))
    get :show, id: stickies(:viewable_by_valid)
    assert_nil assigns(:sticky)
    assert_redirected_to stickies_path
  end

  test "should get edit" do
    get :edit, id: @sticky
    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:project_id)
    assert_response :success
  end

  test "should not edit but show for project viewers" do
    get :edit, id: stickies(:viewable_by_valid)
    assert_not_nil assigns(:sticky)
    assert_redirected_to sticky_path(stickies(:viewable_by_valid))
  end

  test "should not edit for users not on project" do
    login(users(:two))
    get :edit, id: stickies(:viewable_by_valid)
    assert_nil assigns(:sticky)
    assert_redirected_to root_path
  end

  test "should move sticky to new board" do
    post :move_to_board, id: @sticky, board_id: boards(:two), format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal boards(:two), assigns(:sticky).board
    assert_template 'move_to_board'
    assert_response :success
  end

  test "should move sticky to holding pen" do
    post :move_to_board, id: @sticky, board_id: 0, format: 'js'

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).board
    assert_template 'move_to_board'
    assert_response :success
  end

  test "should not move sticky to new board for project viewers" do
    post :move_to_board, id: stickies(:viewable_by_valid), board_id: boards(:two), format: 'js'

    assert_nil assigns(:sticky)
    assert_nil stickies(:viewable_by_valid).board
    assert_response :success
  end

  test "should move sticky on calendar" do
    post :move, id: @sticky, due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal Time.zone.local(2012, 3, 7, 0, 0, 0), assigns(:sticky).due_date
    assert_template 'update'
    assert_response :success
  end

  test "should move grouped sticky and shift grouped incomplete stickies by original sticky shift" do
    put :move, id: stickies(:grouped_one), due_date: "12/06/2011", shift: 'incomplete', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal Time.zone.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-02'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: true).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_equal ['2011-12-08', '2011-12-09', '2011-12-10', ''], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: false).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_template 'groups/update'
    assert_response :success
  end

  test "should move sticky on calendar and keep due at time" do
    post :move, id: stickies(:due_at), due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal Time.utc(2012, 3, 7, 14, 0, 0), assigns(:sticky).due_date.utc
    assert_template 'update'
    assert_response :success
  end

  test "should not move sticky on calendar for project viewers" do
    post :move, id: stickies(:viewable_by_valid), due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal stickies(:viewable_by_valid).due_date, assigns(:sticky).due_date
    assert_template 'update'
    assert_response :success
  end

  test "should not move for users not on project" do
    login(users(:two))
    post :move, id: @sticky, due_date: "03/07/2012", format: 'js'
    assert_nil assigns(:sticky)
    assert_response :success
  end

  test "should complete sticky" do
    post :complete, id: @sticky, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal true, assigns(:sticky).completed
    assert_template 'complete_multiple'
    assert_response :success
  end

  test "should complete sticky from calendar" do
    post :complete, id: @sticky, from: 'month', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal true, assigns(:sticky).completed
    assert_template 'update'
    assert_response :success
  end

  test "should complete sticky and repeat on the following day" do
    assert_difference('Sticky.count', 1) do
      post :complete, id: stickies(:repeat_daily), format: 'js'
    end
    assert_not_nil assigns(:sticky)
    assert_equal true, assigns(:sticky).completed
    assert_not_nil assigns(:sticky).repeated_sticky
    assert_equal false, assigns(:sticky).repeated_sticky.completed
    assert_equal Time.utc(2013, 1, 3, 5, 0, 0), assigns(:sticky).repeated_sticky.due_date.utc
    assert_template 'complete_multiple'
    assert_response :success
  end

  test "should not complete sticky for viewer" do
    post :complete, id: stickies(:viewable_by_valid), format: 'js'
    assert_nil assigns(:sticky)
    assert_response :success
  end

  test "should complete multiple stickies" do
    post :complete_multiple, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'
    assert_not_nil assigns(:stickies)
    assert_equal 4, assigns(:stickies).size
    assert_equal [true], assigns(:stickies).collect{|s| s.completed}.uniq
    assert_template 'complete_multiple'
    assert_response :success
  end

  test "should complete multiple stickies for single sticky" do
    post :complete_multiple, sticky_ids: [stickies(:one).id].join(','), format: 'js'
    assert_not_nil assigns(:stickies)
    assert_equal 1, assigns(:stickies).size
    assert_equal [true], assigns(:stickies).collect{|s| s.completed}.uniq
    assert_template 'complete_multiple'
    assert_response :success
  end

  test "should undo completion of multiple stickies" do
    post :complete_multiple, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), undo: 'true', format: 'js'
    assert_not_nil assigns(:stickies)
    assert_equal 4, assigns(:stickies).size
    assert_equal [false], assigns(:stickies).collect{|s| s.completed}.uniq
    assert_template 'complete_multiple'
    assert_response :success
  end

  test "should not complete multiple stickies with invalid ids" do
    post :complete_multiple, sticky_ids: [-1].join(','), format: 'js'
    assert_equal [], assigns(:stickies)
    assert_response :success
  end

  test "should update sticky" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky as json" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, format: 'json'

    sticky = JSON.parse(@response.body)
    assert_equal assigns(:sticky).id, sticky['id']
    assert_equal true, sticky['completed']
    assert_equal "Sticky Description Update", sticky['description']

    assert_response :success
  end

  test "should update sticky and create a new board for the sticky" do
    assert_difference('Board.count') do
      put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: 'New Board'
    end

    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:board)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:board).name, assigns(:sticky).board.name
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky and assign to existing board" do
    assert_difference('Board.count', 0) do
      put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, create_new_board: '0', sticky_board_name: 'New Board'
    end

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:board)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky and set without a board" do
    assert_difference('Board.count', 0) do
      put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: ''
    end

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:board)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_nil assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky and assign to existing board found by board name" do
    assert_difference('Board.count', 0) do
      put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, create_new_board: '1', sticky_board_name: 'Board One'
    end

    assert_not_nil assigns(:sticky)
    assert_not_nil boards(:one)
    assert_equal boards(:one), assigns(:board)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky and redirect to project page and board" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, from: 'project', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_template 'update'
  end

  test "should update sticky with due time and duration" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, due_date: "08/15/2011", due_at_string: '10am', duration: '1', duration_units: 'hours' }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal Time.zone.local(2011, 8, 15, 10, 0, 0), assigns(:sticky).due_date
    assert_equal "10:00 AM", assigns(:sticky).due_at_string
    assert_equal "11:00 AM (1 hours)", assigns(:sticky).due_at_end_string_with_duration
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky with blank due time and duration" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011", due_at_string: 'wrong time', duration: '', duration_units: '' }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal "", assigns(:sticky).due_at_string
    assert_equal "", assigns(:sticky).due_at_end_string_with_duration
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  # Stickies in groups can only have their project changed by editing the group meta data
  test "should update sticky in a group but not change project" do
    put :update, id: stickies(:grouped), sticky: { description: "Sticky Description Update", project_id: projects(:two).to_param, board_id: boards(:three).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board # Should keep original board or nil since sticky board must be in same project
    assert_equal projects(:one), assigns(:sticky).project # Should keep original project since grouped stickies can only be moved to another project from editing the group
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky from calendar" do
    put :update, id: @sticky, from: 'month', sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_template 'update'
  end

  test "should update sticky and remove all tags" do
    put :update, id: stickies(:tagged), from: 'month', sticky: { description: "Sticky Tags Removed", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011", tag_ids: [""] }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal [], assigns(:sticky).tags
    assert_equal "Sticky Tags Removed", assigns(:sticky).description
    assert_equal false, assigns(:sticky).completed
    assert_nil assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_template 'update'
  end

  test "should update sticky and add tags" do
    put :update, id: @sticky, from: 'month', sticky: { description: "Sticky Tags Added", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '0', due_date: "08/15/2011", tag_ids: [tags(:alpha).to_param] }, format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal ['alpha'], assigns(:sticky).tags.collect{|t| t.name}
    assert_equal "Sticky Tags Added", assigns(:sticky).description
    assert_equal false, assigns(:sticky).completed
    assert_nil assigns(:sticky).end_date
    assert_equal Time.zone.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal boards(:one), assigns(:sticky).board
    assert_equal projects(:one), assigns(:sticky).project
    assert_template 'update'
  end

  test "should update sticky and not shift grouped stickies" do
    put :update, id: stickies(:grouped_one), from: 'month', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, board_id: stickies(:grouped_one).board_id, completed: '0', due_date: "12/06/2011" }, shift: 'single', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal Time.zone.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-02', '2011-12-03', '2011-12-04', '2011-12-05', ''], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_template 'update'
  end

  test "should update sticky and shift grouped incomplete stickies by original sticky shift" do
    put :update, id: stickies(:grouped_one), from: 'month', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, board_id: stickies(:grouped_one).board_id, completed: '0', due_date: "12/06/2011" }, shift: 'incomplete', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal Time.zone.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-02'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: true).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_equal ['2011-12-08', '2011-12-09', '2011-12-10', ''], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: false).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_template 'update'
  end

  test "should update sticky and shift grouped stickies by original sticky shift" do
    put :update, id: stickies(:grouped_one), from: 'month', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, board_id: stickies(:grouped_one).board_id, completed: '0', due_date: "12/06/2011" }, shift: 'all', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal Time.zone.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-07', '2011-12-08', '2011-12-09', '2011-12-10', ''], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_template 'update'
  end

  test "should not update sticky with blank description" do
    put :update, id: @sticky, sticky: { description: "", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:description]
    assert_template 'edit'
  end

  test "should not update sticky with blank project" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: nil, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:project_id]
    assert_template 'edit'
  end

  test "should not update sticky with invalid id" do
    put :update, id: -1, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, board_id: boards(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_nil assigns(:sticky)
    assert_redirected_to stickies_path
  end

  test "should update planned sticky and not set end_date" do
    put :update, id: stickies(:planned), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }

    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update planned sticky to ongoing and not set end_date" do
    put :update, id: stickies(:planned), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update planned sticky to completed and set end_date" do
    put :update, id: stickies(:planned), sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky and not set end_date" do
    put :update, id: stickies(:ongoing), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky to planned and not set end_date" do
    put :update, id: stickies(:ongoing), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky to completed and set end_date" do
    put :update, id: stickies(:ongoing), sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky and not reset end_date" do
    put :update, id: stickies(:completed), sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal stickies(:completed).end_date, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky to planned and clear end_date" do
    put :update, id: stickies(:completed), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky to ongoing and clear end_date" do
    put :update, id: stickies(:completed), sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should destroy sticky" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, id: @sticky
    end
    assert_not_nil assigns(:sticky)
    assert_redirected_to month_path( date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%Y%m%d') )
  end

  test "should destroy sticky and all following" do
    assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.where("due_date >= ?", stickies(:grouped_two).due_date).size) do
      delete :destroy, id: stickies(:grouped_two), discard: 'following'
    end
    assert_not_nil assigns(:sticky)
    # Two remain since a sticky without a due date wouldn't be deleted since it's not "following" or "preceding"
    assert_equal 2, assigns(:sticky).group.stickies.size
    assert_redirected_to month_path( date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%Y%m%d') )
  end

  test "should destroy sticky and all in group" do
    assert_difference('Group.current.count', -1) do
      assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.size) do
        delete :destroy, id: stickies(:grouped_two), discard: 'all'
      end
    end
    assert_not_nil assigns(:sticky)
    assert_equal 0, assigns(:sticky).group.stickies.size
    assert_redirected_to month_path( date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%Y%m%d') )
  end

  test "should destroy sticky from calendar" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, from: 'month', id: @sticky, format: 'js'
    end
    assert_not_nil assigns(:sticky)
    assert_template 'destroy'
  end

  test "should not destroy sticky without valid id" do
    assert_difference('Sticky.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:sticky)
    assert_redirected_to stickies_path
  end

  test "should not destroy sticky using ajax without valid id" do
    assert_difference('Sticky.current.count', 0) do
      delete :destroy, id: -1, format: 'js'
    end

    assert_nil assigns(:sticky)
    assert_response :success
  end

  test "should destroy multiple stickies" do
    assert_difference('Sticky.current.count', -4) do
      post :destroy_multiple, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'
    end

    assert_not_nil assigns(:stickies)
    assert_template 'destroy_multiple'
    assert_response :success
  end

  test "should not destroy multiple stickies without valid ids" do
    assert_difference('Sticky.current.count', 0) do
      post :destroy_multiple, sticky_ids: [-1].join(','), format: 'js'
    end

    assert_equal [], assigns(:stickies)
    assert_response :success
  end
end
