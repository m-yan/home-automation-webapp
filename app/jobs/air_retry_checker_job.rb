class AirRetryCheckerJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) { }

  def perform(event)
    begin
      @event = event
      first_operation = event.operations.first
      target_device = first_operation.device
      raise ArgumentError, 'Invalid Argument. Device type mismatch.' unless target_device.instance_of?(Air)

      if need_to_retry?(target_device) && retry_ok?(target_device)
        retry_operation = first_operation.dup
        retry_operation.operation_detail = first_operation.operation_detail.dup
        retry_operation.send_request
        event.operations << retry_operation
        raise "Error. Environmental change is different from the expected."
      end
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      raise
    end
  end

  protected
    def need_to_retry?(target_device)      
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def retry_ok?(target_device)
      return target_device.status.reload.try(:retry_job_id) == self.job_id
    end

    def get_temperature(sensor)
      operation = @event.operations.new(operation_type_id: GET_TEMPERATURE_OPERATION_TYPE_ID, device: sensor)
      ret = operation.send_request
      @event.save

      raise "Error in HGW response." unless ret
      return HgwIfParameters.build_from_xml(operation.response).temperature
    end

    def get_humidity(sensor)
      operation = @event.operations.new(operation_type_id: GET_HUMIDITY_OPERATION_TYPE_ID, device: sensor)
      ret = operation.send_request
      @event.save

      raise "Error in HGW response." unless ret
      return HgwIfParameters.build_from_xml(operation.response).humidity
    end
end
