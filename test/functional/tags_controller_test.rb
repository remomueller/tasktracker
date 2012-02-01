require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @tag = tags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tag" do
    assert_difference('Tag.count') do
      post :create, tag: { name: "Tag Name", project_id: projects(:one).to_param, description: "" }
    end

    assert_not_nil assigns(:tag)
    assert_equal users(:valid).to_param, assigns(:tag).user_id.to_s

    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should not create tag with blank name" do
    assert_difference('Tag.count', 0) do
      post :create, tag: { name: "", project_id: projects(:one).to_param, description: "" }
    end

    assert_not_nil assigns(:tag)
    assert_template 'new'
  end

  test "should show tag" do
    get :show, id: @tag.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tag.to_param
    assert_response :success
  end

  test "should update tag" do
    put :update, id: @tag.to_param, tag: { name: "Tag Name Update", project_id: projects(:one).to_param, description: "Updated Description", color: '#aaaaaa' }
    assert_not_nil assigns(:tag)
    assert_equal 'Tag Name Update', assigns(:tag).name
    assert_equal 'Updated Description', assigns(:tag).description
    assert_equal projects(:one).to_param, assigns(:tag).project_id.to_s
    assert_equal '#aaaaaa', assigns(:tag).color
    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should not update tag with blank name" do
    put :update, id: @tag.to_param, tag: { name: "", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_not_nil assigns(:tag)
    assert_template 'edit'
  end

  test "should not update tag with non-unique name" do
    put :update, id: @tag.to_param, tag: { name: "MyStringTwo", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_not_nil assigns(:tag)
    assert assigns(:tag).errors.size > 0
    assert_equal ["has already been taken"], assigns(:tag).errors[:name]
    assert_template 'edit'
  end

  test "should not update tag with invalid id" do
    put :update, id: -1, tag: { name: "Tag Name Update", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_nil assigns(:tag)
    assert_redirected_to root_path
  end

  test "should destroy tag" do
    assert_difference('Tag.current.count', -1) do
      delete :destroy, id: @tag.to_param
    end

    assert_redirected_to tags_path
  end

  test "should not destroy with invalid id" do
    assert_difference('Tag.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:tag)
    assert_redirected_to root_path
  end
end
