require 'test_helper'

class StickiesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sticky = stickies(:one)
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
    assert_equal Date.strptime('08/15/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal assigns(:sticky).user_id.to_s, users(:valid).to_param
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should create sticky from calendar" do
    assert_difference('Sticky.count') do
      post :create, from_calendar: 1, sticky: { description: "Sticky Description", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '0', due_date: "08/15/2011" }
    end

    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description", assigns(:sticky).description
    assert_equal projects(:one), assigns(:sticky).project
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal false, assigns(:sticky).completed
    assert_equal Date.strptime('08/15/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
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
    get :show, id: @sticky.to_param
    assert_response :success
  end

  test "should show sticky with group description" do
    get :show, id: stickies(:grouped).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sticky.to_param
    assert_not_nil assigns(:sticky)
    assert_not_nil assigns(:project_id)
    assert_response :success
  end

  test "should not edit but show for project viewers" do
    get :edit, id: stickies(:viewable_by_valid).to_param
    assert_not_nil assigns(:sticky)
    assert_redirected_to sticky_path(stickies(:viewable_by_valid))
  end
  
  test "should not edit for users not on project" do
    login(users(:two))
    get :edit, id: stickies(:viewable_by_valid).to_param
    assert_nil assigns(:sticky)
    assert_redirected_to root_path
  end

  test "should update sticky" do
    put :update, id: @sticky.to_param, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Date.strptime('08/15/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  # Stickies in groups can only have their project changed by editing the group meta data
  test "should update sticky in a group but not change project" do
    put :update, id: stickies(:grouped).to_param, sticky: { description: "Sticky Description Update", project_id: projects(:two).to_param, frame_id: frames(:three).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Date.strptime('08/15/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame # Should keep original frame or nil since sticky frame must be in same project
    assert_equal projects(:one), assigns(:sticky).project # Should keep original project since grouped stickies can only be moved to another project from editing the group
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update sticky from calendar" do
    put :update, id: @sticky.to_param, from_calendar: 1, sticky: { description: "Sticky Description Update", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal "Sticky Description Update", assigns(:sticky).description
    assert_equal true, assigns(:sticky).completed
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal Date.strptime('08/15/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal frames(:one), assigns(:sticky).frame
    assert_equal projects(:one), assigns(:sticky).project
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky in a group and not shift the remaining stickies" do
    put :update, id: stickies(:grouped_one).to_param, from_calendar: 1, sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'single'
    assert_not_nil assigns(:sticky)
    assert_equal Date.strptime('12/06/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal ['', '2011-12-02', '2011-12-03', '2011-12-04', '2011-12-05'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky in a group and shift the remaining incomplete stickies based on the amount the original sticky shifted" do
    put :update, id: stickies(:grouped_one).to_param, from_calendar: 1, sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'incomplete'
    assert_not_nil assigns(:sticky)
    assert_equal Date.strptime('12/06/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal ['2011-12-02'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: true).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_equal ['', '2011-12-08', '2011-12-09', '2011-12-10'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).where(completed: false).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should update sticky in a group and shift all other stickies based on the amount the original sticky shifted" do
    put :update, id: stickies(:grouped_one).to_param, from_calendar: 1, sticky: { description: "Shifting sticky forward 5 days", project_id: stickies(:grouped_one).project_id, frame_id: stickies(:grouped_one).frame_id, completed: '0', due_date: "12/06/2011" }, shift: 'all'
    assert_not_nil assigns(:sticky)
    assert_equal Date.strptime('12/06/2011', '%m/%d/%Y'), assigns(:sticky).due_date
    assert_equal ['', '2011-12-07', '2011-12-08', '2011-12-09', '2011-12-10'], assigns(:sticky).group.stickies.where("stickies.id != ?", assigns(:sticky).to_param).order('due_date').collect{|s| s.due_date.blank? ? '' : s.due_date.strftime('%Y-%m-%d')}
    assert_redirected_to calendar_stickies_path(selected_date: assigns(:sticky).due_date.blank? ? '' : assigns(:sticky).due_date.strftime('%m/%d/%Y'))
  end

  test "should not update sticky with blank description" do
    put :update, id: @sticky.to_param, sticky: { description: "", project_id: projects(:one).to_param, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
    assert_not_nil assigns(:sticky)
    assert assigns(:sticky).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sticky).errors[:description]
    assert_template 'edit'
  end

  test "should not update sticky with blank project" do
    put :update, id: @sticky.to_param, sticky: { description: "Sticky Description Update", project_id: nil, frame_id: frames(:one).to_param, completed: '1', due_date: "08/15/2011" }
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
    put :update, id: stickies(:planned).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update planned sticky to ongoing and not set end_date" do
    put :update, id: stickies(:planned).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end
  
  test "should update planned sticky to completed and set end_date" do
    put :update, id: stickies(:planned).to_param, sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky and not set end_date" do
    put :update, id: stickies(:ongoing).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky to planned and not set end_date" do
    put :update, id: stickies(:ongoing).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update ongoing sticky to completed and set end_date" do
    put :update, id: stickies(:ongoing).to_param, sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal Date.today, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky and not reset end_date" do
    put :update, id: stickies(:completed).to_param, sticky: { description: "Sticky Description Update", completed: '1', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_equal stickies(:completed).end_date, assigns(:sticky).end_date
    assert_equal true, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky to planned and clear end_date" do
    put :update, id: stickies(:completed).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should update completed sticky to ongoing and clear end_date" do
    put :update, id: stickies(:completed).to_param, sticky: { description: "Sticky Description Update", completed: '0', due_date: "12/15/2011" }
    assert_not_nil assigns(:sticky)
    assert_nil assigns(:sticky).end_date
    assert_equal false, assigns(:sticky).completed
    assert_redirected_to sticky_path(assigns(:sticky))
  end

  test "should destroy sticky" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, id: @sticky.to_param
    end
    assert_not_nil assigns(:sticky)
    assert_redirected_to stickies_path
  end
  
  test "should destroy sticky and all following" do
    assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.where("due_date >= ?", stickies(:grouped_two).due_date).size) do
      delete :destroy, id: stickies(:grouped_two).to_param, discard: 'following'
    end
    assert_not_nil assigns(:sticky)
    # Two remain since a sticky without a due date wouldn't be deleted since it's not "following" or "preceding"
    assert_equal 2, assigns(:sticky).group.stickies.size
    assert_redirected_to stickies_path
  end

  test "should destroy sticky and all in group" do
    assert_difference('Group.current.count', -1) do
      assert_difference('Sticky.current.count', -1 * stickies(:grouped_two).group.stickies.size) do
        delete :destroy, id: stickies(:grouped_two).to_param, discard: 'all'
      end
    end
    assert_not_nil assigns(:sticky)
    assert_equal 0, assigns(:sticky).group.stickies.size
    assert_redirected_to stickies_path
  end
  
  test "should destroy sticky from calendar" do
    assert_difference('Sticky.current.count', -1) do
      delete :destroy, from_calendar: 1, id: @sticky.to_param
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
end
