require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @tag = tags(:one)
  end

  test "should add stickies to tag" do
    post :add_stickies, project_id: projects(:one), tag_id: tags(:one), sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'

    assert_not_nil assigns(:tag)
    assert_not_nil assigns(:stickies)
    assert_equal 4, assigns(:stickies).size
    assert_equal [tags(:one).id], assigns(:stickies).collect{|s| s.tags.collect{|t| t.id}}.flatten.uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should remove tag from stickies if all stickies have the tag" do
    post :add_stickies, project_id: projects(:one), tag_id: tags(:alpha), sticky_ids: [stickies(:tagged).id, stickies(:only_alpha).id].join(','), format: 'js'

    assert_not_nil assigns(:tag)
    assert_not_nil assigns(:stickies)
    assert_equal 2, assigns(:stickies).size
    assert_equal [tags(:beta).id], assigns(:stickies).collect{|s| s.tags.collect{|t| t.id}}.flatten.uniq
    assert_template 'add_stickies'
    assert_response :success
  end

  test "should not add stickies to tag with invalid id" do
    post :add_stickies, project_id: projects(:one), tag_id: -1, sticky_ids: [stickies(:one).id, stickies(:assigned_to_user).id, stickies(:planned).id, stickies(:completed).id].join(','), format: 'js'

    assert_nil assigns(:tag)
    assert_response :success
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

  test "should create tag with a name identical to a deleted tag" do
    assert_difference('Tag.count') do
      post :create, tag: { name: "Deleted Tag", project_id: projects(:one).to_param, description: "" }
    end

    assert_not_nil assigns(:tag)
    assert_equal "Deleted Tag", assigns(:tag).name
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
    get :show, id: @tag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tag
    assert_response :success
  end

  test "should update tag" do
    put :update, id: @tag, tag: { name: "Tag Name Update", project_id: projects(:one).to_param, description: "Updated Description", color: '#aaaaaa' }
    assert_not_nil assigns(:tag)
    assert_equal 'Tag Name Update', assigns(:tag).name
    assert_equal 'Updated Description', assigns(:tag).description
    assert_equal projects(:one).to_param, assigns(:tag).project_id.to_s
    assert_equal '#aaaaaa', assigns(:tag).color
    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should not update tag with blank name" do
    put :update, id: @tag, tag: { name: "", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_not_nil assigns(:tag)
    assert_template 'edit'
  end

  test "should not update tag with non-unique name" do
    put :update, id: @tag, tag: { name: "MyStringTwo", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_not_nil assigns(:tag)
    assert assigns(:tag).errors.size > 0
    assert_equal ["has already been taken"], assigns(:tag).errors[:name]
    assert_template 'edit'
  end

  test "should not update tag with invalid id" do
    put :update, id: -1, tag: { name: "Tag Name Update", project_id: projects(:one).to_param, description: "Updated Description" }
    assert_nil assigns(:tag)
    assert_redirected_to tags_path
  end

  test "should destroy tag" do
    assert_difference('Tag.current.count', -1) do
      delete :destroy, id: @tag
    end

    assert_redirected_to tags_path(project_id: @tag.project_id)
  end

  test "should not destroy with invalid id" do
    assert_difference('Tag.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:tag)
    assert_redirected_to tags_path
  end
end
