require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sticky = stickies(:one)
  end

  test "should get popup" do
    post :popup, id: stickies(:due_at_ics), format: 'js'
    assert_template 'popup'
    assert_response :success
  end

  test "should get csv" do
    get :index, format: 'csv', status: ['completed', 'not completed']
    assert_not_nil assigns(:csv_string)
    assert_not_nil assigns(:count)
    assert_response :success
  end

  test "should get ics" do
    get :index, format: 'ics', status: ['completed', 'not completed']
    assert_not_nil assigns(:ics_string)
    assert_not_nil assigns(:count)
    assert_response :success
  end

  test "should get calendar" do
    get :calendar
    assert_not_nil assigns(:selected_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'calendar'
  end

  test "should get calendar and set user calendar status" do
    get :calendar, status: ['completed'], save_settings: '1', format: 'js', selected_date: '12/01/2011'
    users(:valid).reload # Needs reload to avoid stale object
    assert_equal ['completed'], users(:valid).settings[:calendar_status]
    assert_not_nil assigns(:selected_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'calendar'
  end

  test "should set assigned_to_me status" do
    get :calendar, assigned_to_me: '1', save_settings: '1', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_equal '1', users(:valid).settings[:assigned_to_me]
    assert_template 'calendar'
  end

  test "should unset assigned_to_me status" do
    get :calendar, save_settings: '1', status: ['planned', 'completed'], selected_date: '12/01/2011', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_equal '0', users(:valid).settings[:assigned_to_me]
    assert_template 'calendar'
  end

  test "should not change assigned_to_me status" do
    get :calendar
    users(:valid).reload # Needs reload to avoid stale object
    assert_equal '', users(:valid).settings[:assigned_to_me].to_s
    assert_template 'calendar'
  end

  test "should get calendar by due date" do
    get :calendar, format: 'js'
    assert_not_nil assigns(:selected_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'calendar'
  end

  test "should get calendar stickies by start date" do
    get :calendar, date_type: 'start_date', format: 'js'
    assert_not_nil assigns(:selected_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'calendar'
  end

  test "should get calendar stickies by end date" do
    get :calendar, date_type: 'end_date', format: 'js'
    assert_not_nil assigns(:selected_date)
    assert_not_nil assigns(:start_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:first_sunday)
    assert_not_nil assigns(:last_saturday)
    assert_not_nil assigns(:stickies)
    assert_template 'calendar'
  end

  test "should get search" do
    get :search, project_id: projects(:one).to_param, frame_id: frames(:one).to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:frame)
    assert_not_nil assigns(:stickies)
    assert_template 'projects/show'
    assert_response :success
  end

  test "should get search from group" do
    get :search, group_id: groups(:three).to_param, format: 'js'
    assert_not_nil assigns(:group)
    assert_not_nil assigns(:stickies)
    assert_template 'search'
    assert_response :success
  end

  test "should not get search without valid project id" do
    get :search, project_id: -1, frame_id: frames(:one).to_param
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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with all day due date" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011", due_at_string: '' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal true, assigns(:sticky).all_day?
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with due date and due at time" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "03/12/2012", due_at_string: '9pm', duration: '30', duration_units: 'minutes' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.local(2012, 3, 12, 21, 0, 0), assigns(:sticky).due_date
    assert_equal false, assigns(:sticky).all_day?

    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky with blank time and duration" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "03/12/2012", due_at_string: 'wrong time', duration: '0', duration_units: 'minutes' }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.local(2012, 3, 12, 0, 0, 0), assigns(:sticky).due_date
    assert_equal true, assigns(:sticky).all_day?

    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky from calendar" do
    assert_difference('Sticky.count') do
      post :create, from_calendar: '1', sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }, format: 'js'
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_template 'create'
    assert_response :success
  end

  test "should create a planned sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create an ongoing sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create a completed sticky" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "12/10/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).start_date
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed

    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create a sticky with a due time" do
    assert_difference('Sticky.count') do
      post :create, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "12/10/2011", due_at_string: '9pm', duration: '30', duration_units: 'minutes' }
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
      post :create, sticky: { description: "", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:description]
    assert_template 'new'
  end

  test "should not create sticky with blank project" do
    assert_difference('Sticky.count', 0) do
      post :create, sticky: { description: "Sticky Description", project_id: nil, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }
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
    assert_redirected_to root_path
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

  test "should move sticky on calendar" do
    post :move, id: @sticky, due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal Time.local(2012, 3, 7, 0, 0, 0), assigns(:sticky).due_date
    assert_template 'create'
    assert_response :success
  end

  test "should move grouped sticky and shift grouped incomplete stickies by original sticky shift" do
    put :move, id: stickies(:grouped_one), due_date: "12/06/2011", shift: 'incomplete', format: 'js'
    assert_not_nil assigns(:sticky)
    assert_equal Time.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-02'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: true).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_equal ['', '2011-12-08', '2011-12-09', '2011-12-10'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: false).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_template 'groups/create'
    assert_response :success
  end

  test "should move sticky on calendar and keep due_at time" do
    post :move, id: stickies(:due_at_ics), due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal "03/07/2012 09:00", assigns(:sticky).due_date.strftime("%m/%d/%Y %H:%M")
    assert_template 'create'
    assert_response :success
  end

  test "should not move sticky on calendar for project viewers" do
    post :move, id: stickies(:viewable_by_valid), due_date: "03/07/2012", format: 'js'

    assert_not_nil assigns(:sticky)
    assert_equal stickies(:viewable_by_valid).due_date, assigns(:sticky).due_date
    assert_template 'create'
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
    assert_template 'complete'
    assert_response :success
  end

  test "should not complete sticky for viewer" do
    post :complete, id: stickies(:viewable_by_valid), format: 'js'
    assert_nil assigns(:sticky)
    assert_response :success
  end

  test "should update sticky" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky and redirect to project page and frame" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }, from: 'project'
    assert_not_nil assigns(:sticky)
    assert_redirected_to project_path(assigns(:sticky).project, frame_id: assigns(:sticky).frame_id)
  end

  test "should update sticky and redirect to index" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }, from: 'index'
    assert_not_nil assigns(:sticky)
    assert_redirected_to stickies_path
  end

  test "should update sticky with due time and duration" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, due_date: "08/15/2011", due_at_string: '10am', duration: '1', duration_units: 'hours' }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal Time.local(2011, 8, 15, 10, 0, 0), assigns(:sticky).due_date
    assert_equal "10:00 AM", assigns(:sticky).due_at_string
    assert_equal "11:00 AM (1 hours)", assigns(:sticky).due_at_end_string_with_duration
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky with blank due time and duration" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011", due_at_string: 'wrong time', duration: '', duration_units: '' }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal "", assigns(:sticky).due_at_string
    assert_equal "", assigns(:sticky).due_at_end_string_with_duration
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  # Stickies in groups can only have their project changed by editing the group meta data
  test "should update sticky in a group but not change project" do
    put :update, id: stickies(:grouped), sticky: { description: "Sticky Description Update", project_id: projects(:two).to_param, frame_id: frames(:three).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame # Should keep original frame or nil since sticky frame must be in same project
    assert_equal projects(:one), assigns(:sticky).project # Should keep original project since grouped stickies can only be moved to another project from editing the group
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky from calendar" do
    put :update, id: @sticky, from_calendar: '1', sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky and remove all tags" do
    put :update, id: stickies(:tagged), from_calendar: '1', sticky: { description: "Sticky Tags Removed", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal [], assigns(:sticky).tags
    assert_equal "Sticky Tags Removed", assigns(:sticky).description
    assert_equal false, assigns(:sticky).completed
    assert_nil assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky and add tags" do
    put :update, id: @sticky, from_calendar: '1', sticky: { description: "Sticky Tags Added", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011", tag_ids: [tags(:alpha).to_param] }
    assert_not_nil assigns(:sticky)
    assert_equal ['alpha'], assigns(:sticky).tags.collect{|t| t.name}
    assert_equal "Sticky Tags Added", assigns(:sticky).description
    assert_equal false, assigns(:sticky).completed
    assert_nil assigns(:sticky).end_date
    assert_equal Time.local(2011, 8, 15, 0, 0, 0), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky and not shift grouped stickies" do
    put :update, id: stickies(:grouped_one), from_calendar: '1', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'single'
    assert_not_nil assigns(:sticky)
    assert_equal Time.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['', '2011-12-02', '2011-12-03', '2011-12-04', '2011-12-05'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky and shift grouped incomplete stickies by original sticky shift" do
    put :update, id: stickies(:grouped_one), from_calendar: '1', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'incomplete'
    assert_not_nil assigns(:sticky)
    assert_equal Time.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['2011-12-02'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: true).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_equal ['', '2011-12-08', '2011-12-09', '2011-12-10'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: false).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky and shift grouped stickies by original sticky shift" do
    put :update, id: stickies(:grouped_one), from_calendar: '1', sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'all'
    assert_not_nil assigns(:sticky)
    assert_equal Time.local(2011, 12, 6, 0, 0, 0), assigns(:sticky).due_date
    assert_equal ['', '2011-12-07', '2011-12-08', '2011-12-09', '2011-12-10'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should not update sticky with blank description" do
    put :update, id: @sticky, sticky: { description: "", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:description]
    assert_template 'edit'
  end

  test "should not update sticky with blank project" do
    put :update, id: @sticky, sticky: { description: "Sticky Description Update", project_id: nil, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:project_id]
    assert_template 'edit'
  end

  test "should not update sticky with invalid id" do
    put :update, id: -1, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_nil assigns(:sticky)
    assert_redirected_to root_path
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
    assert_redirected_to stickies_path
  end

  test "should destroy sticky with ajax" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, id: @sticky, format: 'js'
    end
    assert_not_nil assigns(:sticky)
    assert_template 'destroy'
    assert_response :success
  end

  test "should destroy sticky and all following" do
    assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.where("due_date >= ?", stickies(:grouped_two).due_date).size) do
      delete :destroy, id: stickies(:grouped_two), discard: 'following'
    end
    assert_not_nil assigns(:sticky)
    # Two remain since a sticky without a due date wouldn't be deleted since it's not "following" or "preceding"
    assert_equal 2, assigns(:sticky).group.stickies.size
    assert_redirected_to stickies_path
  end

  test "should destroy sticky and all in group" do
    assert_difference('Group.current.count', -1) do
      assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.size) do
        delete :destroy, id: stickies(:grouped_two), discard: 'all'
      end
    end
    assert_not_nil assigns(:sticky)
    assert_equal 0, assigns(:sticky).group.stickies.size
    assert_redirected_to stickies_path
  end

  test "should destroy sticky from calendar" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, from_calendar: '1', id: @sticky
    end
    assert_not_nil assigns(:sticky)
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should not destroy sticky without valid id" do
    assert_difference('Sticky.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:sticky)
    assert_redirected_to root_path
  end

  test "should not destroy sticky using ajax without valid id" do
    assert_difference('Sticky.current.count', 0) do
      delete :destroy, id: -1, format: 'js'
    end

    assert_nil assigns(:sticky)
    assert_response :success
  end
end
