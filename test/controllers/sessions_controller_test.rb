require 'test_helper'

class Contour::SessionsControllerTest < ActionController::TestCase

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "return user json object on login" do
    users(:valid).update(password: 'password')

    post :create, user: { email: users(:valid).email, password: 'password' }, format: 'json'

    object = JSON.parse(@response.body)
    assert_equal true, object['success']
    assert_equal users(:valid).id, object['user']['id']
    assert_equal 'FirstName', object['user']['first_name']
    assert_equal 'LastName', object['user']['last_name']
    assert_equal 'valid@example.com', object['user']['email']
    assert object['user'].keys.include?('authentication_token')

    assert_response :success
  end

end
