require 'test_helper'

class ProgramsInstructorsControllerTest < ActionController::TestCase
  setup do
    @programs_instructor = programs_instructors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs_instructors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programs_instructor" do
    assert_difference('ProgramsInstructor.count') do
      post :create, programs_instructor: { instructor_id: @programs_instructor.instructor_id, program_id: @programs_instructor.program_id }
    end

    assert_redirected_to programs_instructor_path(assigns(:programs_instructor))
  end

  test "should show programs_instructor" do
    get :show, id: @programs_instructor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programs_instructor
    assert_response :success
  end

  test "should update programs_instructor" do
    patch :update, id: @programs_instructor, programs_instructor: { instructor_id: @programs_instructor.instructor_id, program_id: @programs_instructor.program_id }
    assert_redirected_to programs_instructor_path(assigns(:programs_instructor))
  end

  test "should destroy programs_instructor" do
    assert_difference('ProgramsInstructor.count', -1) do
      delete :destroy, id: @programs_instructor
    end

    assert_redirected_to programs_instructors_path
  end
end
