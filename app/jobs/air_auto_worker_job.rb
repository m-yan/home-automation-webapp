class AirAutoWorkerJob < ActiveJob::Base
  include ActiveJob::Retry

  queue_as :default

  constant_retry limit: nil, unlimited_retries: true, delay: 300

  def perform air, event
    begin
      air_status = air.status || air.create_status

      if air_status.auto
        ActiveJobCanceller.cancel air_status.auto_job_id if air_status.auto_job_id && air_status.auto_job_id != self.job_id
        air_status.update(auto_job_id: self.job_id)

        operations = AirOptimumAdjuster.process air

        #古いライフログ削除＋ライフログ追加
        first_operation = event.operations.first
        Operation.where(event: event)
                 .where(["created_at > ?", first_operation.created_at])
                 .where(["created_at < ?", Time.now - 10.minutes])
                 .destroy_all
        event.operations << operations
        raise 'auto = true'
      else
        air_status.update(auto_job_id: nil)
      end
    rescue => ex
      logger.fatal ex.message
      raise 'continued.'
    end
  end

end
