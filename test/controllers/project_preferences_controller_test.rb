# frozen_string_literal: true

require 'test_helper'

# Tests to assure that users can set project preferences.
class ProjectPreferencesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test 'should set project color' do
    post :colorpicker, params: { project_id: @project, color: '#aabbcc' }, format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_not_nil assigns(:project)
    assert_equal '#aabbcc', users(:valid).project_preferences.where(project: @project).first.color
    assert_response :success
  end

  test 'should not set project color' do
    post :colorpicker, params: { project_id: -1, color: '#aabbcc' }, format: 'js'
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should create project favorite' do
    assert_difference('ProjectPreference.where(favorite: true).count') do
      patch :update, params: { project_id: projects(:one), favorite: '1' }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'update'
    assert_response :success
  end

  test 'should not create project favorite without valid id' do
    assert_difference('ProjectPreference.where(favorite: true).count', 0) do
      patch :update, params: { project_id: -1, favorite: '1' }, format: 'js'
    end
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should remove project favorite' do
    assert_difference('ProjectPreference.where(favorite: false).count') do
      patch :update, params: { project_id: projects(:two), favorite: '0' }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'update'
    assert_response :success
  end

  test 'should enable project emails' do
    login(users(:associated))
    assert_difference('ProjectPreference.where(emails_enabled: true).count') do
      patch :update, params: { project_id: projects(:one), emails_enabled: '1' }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:project_preference)
    assert_template 'update'
    assert_response :success
  end

  test 'should disable project emails' do
    assert_difference('ProjectPreference.where(emails_enabled: false).count') do
      patch :update, params: { project_id: projects(:one), emails_enabled: '0' }, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'update'
    assert_response :success
  end
end
