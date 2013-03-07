require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @template = templates(:one)
  end

  test "should get copy" do
    get :copy, id: @template
    assert_not_nil assigns(:template)
    assert_template 'new'
    assert_response :success
  end

  test "should not get copy for invalid template" do
    get :copy, id: -1
    assert_nil assigns(:template)
    assert_redirected_to templates_path
  end

  test "should get selection" do
    post :selection, group: { template_id: templates(:one) }, format: 'js'
    assert_not_nil assigns(:template)
    assert_template 'selection'
  end

  test "should not get selection without valid project id" do
    post :selection, group: { template_id: -1 }, format: 'js'
    assert_nil assigns(:template)
    assert_response :success
  end

  test "should add item" do
    post :add_item, template: @template.attributes, format: 'js'
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:item)
    assert_template 'add_item'
  end

  test "should get items" do
    post :items, template: @template.attributes, format: 'js'
    assert_not_nil assigns(:template)
    assert_template 'items'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:templates)
  end

  test "should get index for api user using service account" do
    login(users(:service_account))
    get :index, api_token: 'screen_token', screen_token: users(:valid).screen_token, format: 'json'
    assert_not_nil assigns(:templates)
    templates = JSON.parse(@response.body)
    assert templates.first.keys.include?('id')
    assert templates.first.keys.include?('items')
    assert templates.first.keys.include?('full_name')
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create template" do
    assert_difference('Template.count') do
      post :create, template: { name: 'Template Name', project_id: projects(:one).to_param, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    end

    assert_redirected_to template_path(assigns(:template))
  end

  test "should create template as json" do
    assert_difference('Template.count') do
      post :create, template: { name: 'Template Name', project_id: projects(:one).to_param, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }, format: 'json'
    end

    template = JSON.parse(@response.body)
    assert_equal assigns(:template).id, template['id']
    assert_equal assigns(:template).full_name, template['full_name']
    assert_equal assigns(:template).name, template['name']
    assert_equal assigns(:template).project_id, template['project_id']
    assert_equal assigns(:template).avoid_weekends, template['avoid_weekends']
    assert_equal Array, template['items'].class
    assert_equal assigns(:template).user_id, template['user_id']

    assert_response :success
  end

  test "should not create template with blank name" do
    assert_difference('Template.count', 0) do
      post :create, template: { name: '', project_id: projects(:one).to_param, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    end

    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:name]
    assert_template 'new'
  end

  test "should not create template with blank project" do
    assert_difference('Template.count', 0) do
      post :create, template: { name: 'Template Name', project_id: nil, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    end

    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:project_id]
    assert_template 'new'
  end

  test "should show template" do
    get :show, id: @template
    assert_not_nil assigns(:template)
    assert_response :success
  end

  test "should not show template with invalid id" do
    get :show, id: -1
    assert_nil assigns(:template)
    assert_redirected_to templates_path
  end

  test "should get edit" do
    get :edit, id: @template
    assert_response :success
  end

  test "should update template" do
    put :update, id: @template.to_param, template: @template.attributes
    assert_redirected_to template_path(assigns(:template))
  end

  test "should update template as json" do
    put :update, id: @template.to_param, template: { name: 'Updated Name' }, format: 'json'

    template = JSON.parse(@response.body)
    assert_equal assigns(:template).id, template['id']
    assert_equal 'Updated Name', template['name']

    assert_response :success
  end

  test "should not update template with blank name" do
    put :update, id: @template, template: { name: '', project_id: projects(:one).to_param, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:name]
    assert_template 'edit'
  end

  test "should not update template with blank project" do
    put :update, id: @template, template: { name: 'Updated Name', project_id: nil, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:project_id]
    assert_template 'edit'
  end

  test "should not update template with invalid id" do
    put :update, id: -1, template: { name: 'Updated Name', project_id: nil, item_tokens: [ { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } ] }
    assert_nil assigns(:template)
    assert_redirected_to templates_path
  end

  test "should destroy template" do
    assert_difference('Template.current.count', -1) do
      delete :destroy, id: @template
    end
    assert_not_nil assigns(:template)
    assert_redirected_to templates_path(project_id: @template.project_id)
  end

  test "should not destroy template with invalid id" do
    assert_difference('Template.current.count', 0) do
      delete :destroy, id: -1
    end
    assert_nil assigns(:template)
    assert_redirected_to templates_path
  end
end
