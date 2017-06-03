class AirOnCheckerJob < AirRetryCheckerJob
  include ActiveJob::Retry
  constant_retry limit: DEFAULT_RETRY_LIMIT, delay: DELAULT_RETRY_DELAY

  def need_to_retry?(target_device)
    air_status = target_device.status || target_device.create_status

    case air_status.mode
    when AUTO, COOLING, HEATING
      t_sensor = TSensor.nearby(target_device).first
      temperature_before = get_temperature t_sensor

      delta = temperature_before - air_status.temperature
      if delta.abs < TEMPERATURE_DELTA_THRESHOLD  ||
         ( delta > 0 && air_status.mode == HEATING ) ||
         ( delta < 0 && air_status.mode == COOLING )   
        logger.info "Not BLAST mode, but corresponds to it, then exit the processing."
        return false
      end

      sleep AIR_ON_CHECK_WAIT_TIME
      temperature_after = get_temperature t_sensor

      if ( delta > 0 && temperature_after > temperature_before - TEMPERATURE_DELTA_THRESHOLD ) ||
         ( delta < 0 && temperature_after < temperature_before + TEMPERATURE_DELTA_THRESHOLD )
        logger.info "Temperature change is different from the expected."
        return true
      else
        logger.info "Temperature changed as expected."
        return false
      end
       
    when DRY
      h_sensor = HSensor.nearby(target_device).first
      humidity_before = get_humidity h_sensor
      if humidity_before < LOWER_LIMIT_HUMIDITY  
        logger.info "Humidity is low enough then exit the processing."
        return false
      end

      sleep AIR_ON_CHECK_WAIT_TIME
      humidity_after = get_humidity h_sensor

      if humidity_after > humidity_before - HUMIDITY_DELTA_THRESHOLD
        logger.info "Humidity change is different from the expected."
        return true 
      else
        logger.info "Humidity changed as expected."
        return false
      end

    else
      logger.info "Either BLAST or OTHER mode, then exit the processing."
      return false 
    end
  end

end
