require 'test_helper'

class GradeSheetsControllerTest < ActionController::TestCase
  setup do
    @grade_sheet = grade_sheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grade_sheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grade_sheet" do
    assert_difference('GradeSheet.count') do
      post :create, grade_sheet: {  }
    end

    assert_redirected_to grade_sheet_path(assigns(:grade_sheet))
  end

  test "should show grade_sheet" do
    get :show, id: @grade_sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grade_sheet
    assert_response :success
  end

  test "should update grade_sheet" do
    patch :update, id: @grade_sheet, grade_sheet: {  }
    assert_redirected_to grade_sheet_path(assigns(:grade_sheet))
  end

  test "should destroy grade_sheet" do
    assert_difference('GradeSheet.count', -1) do
      delete :destroy, id: @grade_sheet
    end

    assert_redirected_to grade_sheets_path
  end
end
