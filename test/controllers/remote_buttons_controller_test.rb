require 'test_helper'

class RemoteButtonsControllerTest < ActionController::TestCase
  setup do
    @remote_button = remote_buttons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:remote_buttons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remote_button" do
    assert_difference('RemoteButton.count') do
      post :create, remote_button: { button_id: @remote_button.button_id, operation_type_id: @remote_button.operation_type_id, order: @remote_button.order }
    end

    assert_redirected_to remote_button_path(assigns(:remote_button))
  end

  test "should show remote_button" do
    get :show, id: @remote_button
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @remote_button
    assert_response :success
  end

  test "should update remote_button" do
    patch :update, id: @remote_button, remote_button: { button_id: @remote_button.button_id, operation_type_id: @remote_button.operation_type_id, order: @remote_button.order }
    assert_redirected_to remote_button_path(assigns(:remote_button))
  end

  test "should destroy remote_button" do
    assert_difference('RemoteButton.count', -1) do
      delete :destroy, id: @remote_button
    end

    assert_redirected_to remote_buttons_path
  end
end
