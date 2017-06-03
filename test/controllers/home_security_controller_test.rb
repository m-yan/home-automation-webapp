require 'test_helper'

class HomeSecurityControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
