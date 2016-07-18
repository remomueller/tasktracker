# frozen_string_literal: true

require 'test_helper'

# Tests to assure that users can set project preferences.
class ProjectFavoritesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test 'should set project color' do
    post :colorpicker, project_id: @project, color: '#aabbcc', format: 'js'
    users(:valid).reload # Needs reload to avoid stale object
    assert_not_nil assigns(:project)
    assert_equal '#aabbcc', users(:valid).project_favorites.where(project: @project).first.color
    assert_response :success
  end

  test 'should not set project color' do
    post :colorpicker, project_id: -1, color: '#aabbcc', format: 'js'
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should create project favorite' do
    assert_difference('ProjectFavorite.where(favorite: true).count') do
      post :favorite, project_id: projects(:one), favorite: '1', format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'favorite'
  end

  test 'should not create project favorite without valid id' do
    assert_difference('ProjectFavorite.where(favorite: true).count', 0) do
      post :favorite, project_id: -1, favorite: '1', format: 'js'
    end
    assert_nil assigns(:project)
    assert_response :success
  end

  test 'should remove project favorite' do
    assert_difference('ProjectFavorite.where(favorite: false).count') do
      post :favorite, project_id: projects(:two), favorite: '0', format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_template 'favorite'
  end
end
