require 'test_helper'

class ReportControllerTest < ActionController::TestCase
  test "should get new_disnaker" do
    get :new_disnaker
    assert_response :success
  end

  test "should get create_disnaker" do
    get :create_disnaker
    assert_response :success
  end

end
