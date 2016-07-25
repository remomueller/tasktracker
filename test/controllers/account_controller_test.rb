# frozen_string_literal: true

require 'test_helper'

# Test to assure users can update their account settings
class AccountControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:valid)
  end

  def user_params
    {
      first_name: 'FirstUpdate',
      last_name: 'LastUpdate',
      email: 'valid_update@example.com',
      emails_enabled: '0'
    }
  end

  test 'should get stats' do
    login(@regular_user)
    get :stats
    assert_response :success
  end

  test 'should update settings' do
    login(@regular_user)
    post :update_settings, params: { user: user_params }
    @regular_user.reload # Needs reload to avoid stale object
    assert_equal 'FirstUpdate', @regular_user.first_name
    assert_equal 'LastUpdate', @regular_user.last_name
    assert_equal 'valid_update@example.com', @regular_user.email
    assert_equal false, @regular_user.emails_enabled?
    assert_equal 'Your settings have been saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should update settings and enable email' do
    login(users(:send_no_email))
    post :update_settings, params: { user: user_params.merge(emails_enabled: '1') }
    users(:send_no_email).reload # Needs reload to avoid stale object
    assert_equal true, users(:send_no_email).emails_enabled?
    assert_equal 'Your settings have been saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should change password' do
    login(@regular_user)
    patch :change_password, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_equal 'Your password has been changed.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should not change password as user with invalid current password' do
    login(@regular_user)
    patch :change_password, params: {
      user: {
        current_password: 'invalid',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_template 'settings'
    assert_response :success
  end

  test 'should not change password with new password mismatch' do
    login(@regular_user)
    patch :change_password, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'mismatched'
      }
    }
    assert_template 'settings'
    assert_response :success
  end

  test 'should get settings' do
    login(@regular_user)
    get :settings
    assert_response :success
  end
end
