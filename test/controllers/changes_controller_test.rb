require 'test_helper'

class ChangesControllerTest < ActionController::TestCase
  setup do
    @change = changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create change" do
    assert_difference('Change.count') do
      post :create, change: { action: @change.action, action_tstamp: @change.action_tstamp, modified_by: @change.modified_by, new_data: @change.new_data, original_data: @change.original_data, query: @change.query, table_name: @change.table_name }
    end

    assert_redirected_to change_path(assigns(:change))
  end

  test "should show change" do
    get :show, id: @change
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @change
    assert_response :success
  end

  test "should update change" do
    patch :update, id: @change, change: { action: @change.action, action_tstamp: @change.action_tstamp, modified_by: @change.modified_by, new_data: @change.new_data, original_data: @change.original_data, query: @change.query, table_name: @change.table_name }
    assert_redirected_to change_path(assigns(:change))
  end

  test "should destroy change" do
    assert_difference('Change.count', -1) do
      delete :destroy, id: @change
    end

    assert_redirected_to changes_path
  end
end
