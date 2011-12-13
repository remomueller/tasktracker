require 'test_helper'

class TemplatesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @template = templates(:one)
  end

  test "should generate stickies" do
    assert_difference('Sticky.count', @template.items.size) do
      post :generate_stickies, id: @template.to_param, frame_id: frames(:one).to_param
    end
    assert_not_nil assigns(:template)
    assert_equal assigns(:frame), frames(:one)
    assert_equal assigns(:frame_id).to_s, frames(:one).to_param
    assert_redirected_to assigns(:group)
  end

  test "should generate stickies and place them in a group" do
    assert_difference('Sticky.count', @template.items.size) do
      assert_difference('Group.count') do
        post :generate_stickies, id: @template.to_param, frame_id: frames(:one).to_param
      end
    end
    assert_not_nil assigns(:template)
    assert_not_nil assigns(:group)
    assert_equal @template.items.size, assigns(:group).stickies.size
    assert_equal assigns(:frame), frames(:one)
    assert_equal assigns(:frame_id).to_s, frames(:one).to_param
    assert_redirected_to assigns(:group)
  end

  test "should not generate stickies for invalid id" do
    assert_difference('Sticky.count', 0) do
      assert_difference('Group.count', 0) do
        post :generate_stickies, id: -1, frame_id: frames(:one).to_param
      end
    end
    assert_nil assigns(:template)
    assert_nil assigns(:frame)
    assert_nil assigns(:frame_id)
    assert_redirected_to root_path
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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create template" do
    assert_difference('Template.count') do
      post :create, template: @template.attributes
    end

    assert_redirected_to template_path(assigns(:template))
  end

  test "should not create template with blank name" do
    assert_difference('Template.count', 0) do
      post :create, template: { name: '', project_id: projects(:one).to_param, item_tokens: { "1" => { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } } }
    end

    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:name]
    assert_template 'new'
  end

  test "should not create template with blank project" do
    assert_difference('Template.count', 0) do
      post :create, template: { name: 'Template Name', project_id: nil, item_tokens: { "1" => { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } } }
    end

    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:project_id]
    assert_template 'new'
  end

  test "should show template" do
    get :show, id: @template.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @template.to_param
    assert_response :success
  end

  test "should update template" do
    put :update, id: @template.to_param, template: @template.attributes
    assert_redirected_to template_path(assigns(:template))
  end

  test "should not update template with blank name" do
    put :update, id: @template.to_param, template: { name: '', project_id: projects(:one).to_param, item_tokens: { "1" => { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } } }
    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:name]
    assert_template 'edit'
  end

  test "should not update template with blank project" do
    put :update, id: @template.to_param, template: { name: 'Updated Name', project_id: nil, item_tokens: { "1" => { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } } }
    assert_not_nil assigns(:template)
    assert assigns(:template).errors.size > 0
    assert_equal ["can't be blank"], assigns(:template).errors[:project_id]
    assert_template 'edit'
  end

  test "should not update template with invalid id" do
    put :update, id: -1, template: { name: 'Updated Name', project_id: nil, item_tokens: { "1" => { description: 'Reminder in a Week', interval: 1, units: 'weeks', owner_id: users(:valid).to_param } } }
    assert_nil assigns(:template)
    assert_redirected_to root_path
  end

  test "should destroy template" do
    assert_difference('Template.current.count', -1) do
      delete :destroy, id: @template.to_param
    end
    assert_not_nil assigns(:template)
    assert_redirected_to templates_path
  end
  
  test "should not destroy template with invalid id" do
    assert_difference('Template.current.count', 0) do
      delete :destroy, id: -1
    end
    assert_nil assigns(:template)
    assert_redirected_to root_path
  end
end
