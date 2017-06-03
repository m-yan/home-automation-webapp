class HaRoomInEventHandlerJob < ActiveJob::Base
  queue_as :default

  def perform(event)
    detected_device = event.device

    begin
#      i_sensor = ISensor.nearby(detected_device).first
#      get_illuminance = event.operations.new(operation_type: OperationType.find(GET_ILLUMINANCE_OPERATION_TYPE_ID), device: i_sensor)
#      raise "Error in HGW response." unless get_illuminance.send_request
#      illuminance = HgwIfParameters.build_from_xml(get_illuminance.response).illuminance

#      if illuminance > LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE
#        logger.info "There is no need to put the lighting is sufficiently bright."
#        return
#      end

      target_light = Light.nearby(detected_device).first
      event.operations.new(operation_type: OperationType.find(LIGHT_ON_OPERATION_TYPE_ID), device: target_light).send_request # && HaRetryHandler.new(event).handle
      
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
    ensure 
      event.save
    end

  end
end
