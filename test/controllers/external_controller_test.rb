# frozen_string_literal: true

require 'test_helper'

# Test for publicly available pages
class ExternalControllerTest < ActionController::TestCase
  test 'should get about' do
    get :about
    assert_response :success
  end

  test 'should get acceptable use policy' do
    get :use
    assert_response :success
  end

  test 'should get version' do
    get :version
    assert_response :success
  end

  test 'should get version as json' do
    get :version, format: 'json'
    version = JSON.parse(response.body)
    assert_equal TaskTracker::VERSION::STRING, version['version']['string']
    assert_equal TaskTracker::VERSION::MAJOR, version['version']['major']
    assert_equal TaskTracker::VERSION::MINOR, version['version']['minor']
    assert_equal TaskTracker::VERSION::TINY, version['version']['tiny']
    assert_equal TaskTracker::VERSION::BUILD, version['version']['build']
    assert_response :success
  end
end
