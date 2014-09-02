require 'test_helper'

class InstructorsSchedulesControllerTest < ActionController::TestCase
  setup do
    @instructors_schedule = instructors_schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instructors_schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create instructors_schedule" do
    assert_difference('InstructorsSchedule.count') do
      post :create, instructors_schedule: { avail_seat: @instructors_schedule.avail_seat, day: @instructors_schedule.day, instructor_id: @instructors_schedule.instructor_id, schedule_id: @instructors_schedule.schedule_id }
    end

    assert_redirected_to instructors_schedule_path(assigns(:instructors_schedule))
  end

  test "should show instructors_schedule" do
    get :show, id: @instructors_schedule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @instructors_schedule
    assert_response :success
  end

  test "should update instructors_schedule" do
    patch :update, id: @instructors_schedule, instructors_schedule: { avail_seat: @instructors_schedule.avail_seat, day: @instructors_schedule.day, instructor_id: @instructors_schedule.instructor_id, schedule_id: @instructors_schedule.schedule_id }
    assert_redirected_to instructors_schedule_path(assigns(:instructors_schedule))
  end

  test "should destroy instructors_schedule" do
    assert_difference('InstructorsSchedule.count', -1) do
      delete :destroy, id: @instructors_schedule
    end

    assert_redirected_to instructors_schedules_path
  end
end
