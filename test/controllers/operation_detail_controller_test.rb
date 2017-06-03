require 'test_helper'

class OperationDetailControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
