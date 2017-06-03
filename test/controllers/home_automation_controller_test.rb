require 'test_helper'

class HomeAutomationControllerTest < ActionController::TestCase
  test "should get air" do
    get :air
    assert_response :success
  end

  test "should get tv" do
    get :tv
    assert_response :success
  end

  test "should get light" do
    get :light
    assert_response :success
  end

end
