class HaRetryHandler

  RETRY_OPERATION_TYPES = [LIGHT_ON_OPERATION_TYPE_ID, LIGHT_OFF_OPERATION_TYPE_ID, AIR_POWER_ON_OPERATION_TYPE_ID, AIR_POWER_OFF_OPERATION_TYPE_ID]

  def initialize(event)
    @event = event
  end

  def handle
    last_operation = @event.operations.last
    return nil unless RETRY_OPERATION_TYPES.include? last_operation.operation_type_id

    target_device = last_operation.device

    device_status = target_device.status || target_device.create_status    
    if device_status.retry_job_id
      ActiveJobCanceller.cancel device_status.retry_job_id
      device_status.update(retry_job_id: nil)
    end

    case last_operation.operation_type_id
    when LIGHT_ON_OPERATION_TYPE_ID
       job = LightOnCheckerJob.set(wait: RETRY_CHECKER_JOB_WAIT_SECONDS.seconds).perform_later @event
    when LIGHT_OFF_OPERATION_TYPE_ID
       job = LightOffCheckerJob.set(wait: RETRY_CHECKER_JOB_WAIT_SECONDS.seconds).perform_later @event
    when AIR_POWER_ON_OPERATION_TYPE_ID
       job = AirOnCheckerJob.set(wait: RETRY_CHECKER_JOB_WAIT_SECONDS.seconds).perform_later @event
    when AIR_POWER_OFF_OPERATION_TYPE_ID
       job = AirOffCheckerJob.set(wait: RETRY_CHECKER_JOB_WAIT_SECONDS.seconds).perform_later @event
    end
    device_status.update(retry_job_id: job.job_id)

  end

end
