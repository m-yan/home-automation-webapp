class AirOffTimerHandlerJob < ActiveJob::Base
  queue_as :default

  def perform(air_status)
    air_status.update(off_timer: 2, stop_time_relative: nil, off_timer_job_id: nil)
  end
end
