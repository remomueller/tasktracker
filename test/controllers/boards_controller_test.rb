require 'test_helper'

class BoardsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @board = boards(:one)
  end

  test "should archive board" do
    post :archive, id: @board, archived: true, format: 'js'

    assert_not_nil assigns(:board)
    assert_equal true, assigns(:board).archived
    assert_template 'archive'
    assert_response :success
  end

  test "should unarchive board" do
    post :archive, id: @board, archived: false, format: 'js'

    assert_not_nil assigns(:board)
    assert_equal false, assigns(:board).archived
    assert_template 'archive'
    assert_response :success
  end

  test "should add stickies to holding pen" do
    post :add_stickies, project_id: projects(:one), board_id: 0, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'

    assert_not_nil assigns(:stickies)
    assert_equal 4, assigns(:stickies).size
    assert_equal [nil], assigns(:stickies).pluck(:board_id).uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should add stickies to board" do
    post :add_stickies, project_id: projects(:one), board_id: boards(:two), sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'

    assert_not_nil assigns(:stickies)
    assert_equal 4, assigns(:stickies).size
    assert_equal [boards(:two).id], assigns(:stickies).pluck(:board_id).uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should not add stickies to board with invalid id" do
    post :add_stickies, project_id: projects(:one), board_id: -1, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'

    assert_nil assigns(:board)
    assert_response :success
  end

  test "should add stickies in group to board" do
    post :add_stickies, project_id: projects(:one), board_id: boards(:two), sticky_ids: [stickies(:grouped).id].join(','), format: 'js'

    assert_not_nil assigns(:stickies)
    assert_equal 1, assigns(:stickies).size
    assert_equal [boards(:two).id], assigns(:stickies).pluck(:board_id).uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should add stickies in group to holding pen" do
    post :add_stickies, project_id: projects(:one), board_id: 0, sticky_ids: [stickies(:grouped).id].join(','), format: 'js'

    assert_not_nil assigns(:stickies)
    assert_equal 1, assigns(:stickies).size
    assert_equal [nil], assigns(:stickies).pluck(:board_id).uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should not archive board for project viewers" do
    post :archive, id: boards(:four), archived: true, format: 'js'

    assert_nil assigns(:board)
    assert_equal false, boards(:four).archived
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:boards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create board" do
    assert_difference('Board.count') do
      post :create, board: { name: "Board Name", project_id: projects(:one).to_param, description: "", archived: @board.archived }
    end

    assert_not_nil assigns(:board)
    assert_equal assigns(:board).user_id.to_s, users(:valid).to_param

    assert_redirected_to board_path(assigns(:board))
  end

  test "should not create board with blank name" do
    assert_difference('Board.count', 0) do
      post :create, board: { name: "", project_id: projects(:one).to_param, description: "", archived: @board.archived }
    end

    assert_not_nil assigns(:board)
    assert_template 'new'
  end

  test "should show board" do
    get :show, id: @board
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @board
    assert_response :success
  end

  test "should update board" do
    put :update, id: @board, board: { name: "Board Name Update", project_id: projects(:one).to_param, description: "Updated Description", archived: false }
    assert_redirected_to board_path(assigns(:board))
  end

  test "should not update board with blank name" do
    put :update, id: @board, board: { name: "", project_id: projects(:one).to_param, description: "Updated Description", archived: false }
    assert_not_nil assigns(:board)
    assert_template 'edit'
  end

  test "should not update board with invalid id" do
    put :update, id: -1, board: { name: "Board Name Update", project_id: projects(:one).to_param, description: "Updated Description", archived: false }
    assert_nil assigns(:board)
    assert_redirected_to root_path
  end

  test "should destroy board and move attached stickies to project holding pen" do
    assert_difference('Sticky.with_board(0).count', @board.stickies.size) do
      assert_difference('Sticky.current.count', 0) do
        assert_difference('Board.current.count', -1) do
          delete :destroy, id: @board
        end
      end
    end

    assert_equal 0, @board.stickies.size
    assert_redirected_to boards_path(project_id: @board ? @board.project_id : nil)
  end

  test "should not destroy with invalid id" do
    assert_difference('Board.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:board)
    assert_redirected_to boards_path
  end
end
