class LightRetryCheckerJob < ActiveJob::Base
  queue_as :default

  rescue_from(Exception) { } 

  def perform(event)
    begin
      operate_light = event.operations.first
      target_device = operate_light.device
      unless target_device.instance_of?(Light)
        operate_light = event.operations.last
        target_device = operate_light.device
        raise ArgumentError, 'Invalid Argument. Device type mismatch.' unless target_device.instance_of?(Light)
      end

      sensor = ISensor.nearby(target_device).first
      operation = event.operations.new(operation_type_id: GET_ILLUMINANCE_OPERATION_TYPE_ID, device: sensor)
      ret = operation.send_request
      event.save

      raise "Error in HGW response." unless ret
      illuminance = HgwIfParameters.build_from_xml(operation.response).illuminance

      if need_to_retry?(illuminance) && retry_ok?(target_device)
        retry_operation = operate_light.dup
        retry_operation.operation_detail = operate_light.operation_detail.dup
        retry_operation.send_request
        event.operations << retry_operation
        raise "Need to retry."
      end
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      raise 
    end 
  end

  protected
    def need_to_retry?(illuminance)
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def retry_ok?(target_device)
      return target_device.status.reload.try(:retry_job_id) == self.job_id
    end
end
