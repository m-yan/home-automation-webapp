require 'test_helper'

class DeviceStatusesControllerTest < ActionController::TestCase
  setup do
    @device_status = device_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_status" do
    assert_difference('DeviceStatus.count') do
      post :create, device_status: { device_id: @device_status.device_id, enabled: @device_status.enabled, humidity: @device_status.humidity, illuminance: @device_status.illuminance, mode: @device_status.mode, off_timer: @device_status.off_timer, off_timer_job_id: @device_status.off_timer_job_id, on_timer: @device_status.on_timer, on_timer_job_id: @device_status.on_timer_job_id, power: @device_status.power, start_time: @device_status.start_time, status: @device_status.status, stop_time: @device_status.stop_time, temperature: @device_status.temperature, type: @device_status.type, volume: @device_status.volume }
    end

    assert_redirected_to device_status_path(assigns(:device_status))
  end

  test "should show device_status" do
    get :show, id: @device_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @device_status
    assert_response :success
  end

  test "should update device_status" do
    patch :update, id: @device_status, device_status: { device_id: @device_status.device_id, enabled: @device_status.enabled, humidity: @device_status.humidity, illuminance: @device_status.illuminance, mode: @device_status.mode, off_timer: @device_status.off_timer, off_timer_job_id: @device_status.off_timer_job_id, on_timer: @device_status.on_timer, on_timer_job_id: @device_status.on_timer_job_id, power: @device_status.power, start_time: @device_status.start_time, status: @device_status.status, stop_time: @device_status.stop_time, temperature: @device_status.temperature, type: @device_status.type, volume: @device_status.volume }
    assert_redirected_to device_status_path(assigns(:device_status))
  end

  test "should destroy device_status" do
    assert_difference('DeviceStatus.count', -1) do
      delete :destroy, id: @device_status
    end

    assert_redirected_to device_statuses_path
  end
end
