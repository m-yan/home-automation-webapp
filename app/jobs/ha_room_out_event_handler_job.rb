class HaRoomOutEventHandlerJob < ActiveJob::Base
  queue_as :default

  def perform(event)
    detected_device = event.device

    begin
#      air = Air.nearby(detected_device).first
#      air_status = air.status || air.create_status
#      air_status.update_attributes(power: false, auto: false)
#      event.operations.new(operation_type: OperationType.find(AIR_POWER_OFF_OPERATION_TYPE_ID), device: air).send_request # && HaRetryHandler.new(event).handle

#      i_sensor = ISensor.nearby(detected_device).first
#      get_illuminance = event.operations.new(operation_type: OperationType.find(GET_ILLUMINANCE_OPERATION_TYPE_ID), device: i_sensor)
#      raise "Error in HGW response." unless get_illuminance.send_request
#      illuminance = HgwIfParameters.build_from_xml(get_illuminance.response).illuminance

#      if illuminance < LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE
#        logger.info "It is believed that lighting has disappeared because dark."
#        return
#      end

      target_light = Light.nearby(detected_device).first
      event.operations.new(operation_type: OperationType.find(LIGHT_OFF_OPERATION_TYPE_ID), device: target_light).send_request #&& HaRetryHandler.new(event).handle

    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
    ensure
      event.save
    end

  end


end
