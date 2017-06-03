class AirOffCheckerJob < AirRetryCheckerJob
  include ActiveJob::Retry
  constant_retry limit: DEFAULT_RETRY_LIMIT, delay: DELAULT_RETRY_DELAY

  def need_to_retry?(target_device)
    t_sensor = TSensor.nearby(target_device).first
    h_sensor = HSensor.nearby(target_device).first

    temperature_before = get_temperature t_sensor
    humidity_before = get_humidity h_sensor
    sleep AIR_OFF_CHECK_WAIT_TIME

    temperature_after = get_temperature t_sensor
    humidity_after = get_humidity h_sensor

    return (temperature_after - temperature_before).abs < TEMPERATURE_DELTA_THRESHOLD &&
           (humidity_after - humidity_before).abs < HUMIDITY_DELTA_THRESHOLD
  end

end
