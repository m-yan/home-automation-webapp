class AirOnTimerHandlerJob < ActiveJob::Base
  queue_as :default

  def perform(air_status)
    air_status.update(on_timer: 2, start_time_relative: nil, on_timer_job_id: nil)
  end
end
