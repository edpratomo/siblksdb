require 'test_helper'

class StudentsRecordsControllerTest < ActionController::TestCase
  setup do
    @students_record = students_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:students_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create students_record" do
    assert_difference('StudentsRecord.count') do
      post :create, students_record: { finished_on: @students_record.finished_on, modified_at: @students_record.modified_at, modified_by: @students_record.modified_by, pkg_id: @students_record.pkg_id, started_on: @students_record.started_on, status: @students_record.status, student_id: @students_record.student_id }
    end

    assert_redirected_to students_record_path(assigns(:students_record))
  end

  test "should show students_record" do
    get :show, id: @students_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @students_record
    assert_response :success
  end

  test "should update students_record" do
    patch :update, id: @students_record, students_record: { finished_on: @students_record.finished_on, modified_at: @students_record.modified_at, modified_by: @students_record.modified_by, pkg_id: @students_record.pkg_id, started_on: @students_record.started_on, status: @students_record.status, student_id: @students_record.student_id }
    assert_redirected_to students_record_path(assigns(:students_record))
  end

  test "should destroy students_record" do
    assert_difference('StudentsRecord.count', -1) do
      delete :destroy, id: @students_record
    end

    assert_redirected_to students_records_path
  end
end
