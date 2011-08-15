require 'test_helper'

class AuthenticationsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @request.env["omniauth.auth"] = {'provider' => 'google_apps', 'user_info'=> {'email' => 'test@example.com'}}
    @authentication = authentications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:authentications)
  end

  # TODO: Remove
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # TODO Redirects to Authentication Controller if user logged in, if not redirect to user sign up.
  test "should create authentication" do
    assert_difference('Authentication.count') do
      post :create, :authentication => @authentication.attributes
    end

    assert_redirected_to authentications_path
  end

  # TODO: Remove
  # test "should show authentication" do
  #   get :show, :id => @authentication.to_param
  #   assert_response :success
  # end

  # TODO: Remove
  # test "should get edit" do
  #   get :edit, :id => @authentication.to_param
  #   assert_response :success
  # end

  # TODO: Remove
  # test "should update authentication" do
  #   put :update, :id => @authentication.to_param, :authentication => @authentication.attributes
  #   assert_redirected_to authentication_path(assigns(:authentication))
  # end

  test "should destroy authentication" do
    assert_difference('Authentication.count', -1) do
      delete :destroy, :id => @authentication.to_param
    end

    assert_redirected_to authentications_path
  end
end
