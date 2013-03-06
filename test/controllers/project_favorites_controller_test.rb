require 'test_helper'

class ProjectFavoritesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project_favorite = project_favorites(:one)
  end

  # test "the truth" do
  #   assert true
  # end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:project_favorites)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create project_favorite" do
  #   assert_difference('ProjectFavorite.count') do
  #     post :create, project_favorite: @project_favorite.attributes
  #   end
  #
  #   assert_redirected_to project_favorite_path(assigns(:project_favorite))
  # end
  #
  # test "should show project_favorite" do
  #   get :show, id: @project_favorite.to_param
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @project_favorite.to_param
  #   assert_response :success
  # end
  #
  # test "should update project_favorite" do
  #   put :update, id: @project_favorite.to_param, project_favorite: @project_favorite.attributes
  #   assert_redirected_to project_favorite_path(assigns(:project_favorite))
  # end
  #
  # test "should destroy project_favorite" do
  #   assert_difference('ProjectFavorite.count', -1) do
  #     delete :destroy, id: @project_favorite.to_param
  #   end
  #
  #   assert_redirected_to project_favorites_path
  # end
end
