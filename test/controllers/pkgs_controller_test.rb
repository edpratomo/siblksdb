require 'test_helper'

class PkgsControllerTest < ActionController::TestCase
  setup do
    @pkg = pkgs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pkgs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pkg" do
    assert_difference('Pkg.count') do
      post :create, pkg: { level: @pkg.level, pkg: @pkg.pkg, program_id: @pkg.program_id }
    end

    assert_redirected_to pkg_path(assigns(:pkg))
  end

  test "should show pkg" do
    get :show, id: @pkg
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pkg
    assert_response :success
  end

  test "should update pkg" do
    patch :update, id: @pkg, pkg: { level: @pkg.level, pkg: @pkg.pkg, program_id: @pkg.program_id }
    assert_redirected_to pkg_path(assigns(:pkg))
  end

  test "should destroy pkg" do
    assert_difference('Pkg.count', -1) do
      delete :destroy, id: @pkg
    end

    assert_redirected_to pkgs_path
  end
end
