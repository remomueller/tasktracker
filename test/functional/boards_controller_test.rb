require 'test_helper'

class BoardsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @board = boards(:one)
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
      post :create, board: { name: "Board Name", project_id: projects(:one).to_param, description: "", start_date: "08/15/2011", end_date: "12/31/2011" }
    end

    assert_not_nil assigns(:board)
    assert_equal assigns(:board).user_id.to_s, users(:valid).to_param

    assert_redirected_to board_path(assigns(:board))
  end

  test "should not create board with blank name" do
    assert_difference('Board.count', 0) do
      post :create, board: { name: "", project_id: projects(:one).to_param, description: "", start_date: "08/15/2011", end_date: "12/31/2011" }
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
    put :update, id: @board, board: { name: "Board Name Update", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
    assert_redirected_to board_path(assigns(:board))
  end

  test "should not update board with blank name" do
    put :update, id: @board, board: { name: "", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
    assert_not_nil assigns(:board)
    assert_template 'edit'
  end

  test "should not update board with invalid id" do
    put :update, id: -1, board: { name: "Board Name Update", project_id: projects(:one).to_param, description: "Updated Description", start_date: "08/15/2011", end_date: "01/31/2012" }
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
