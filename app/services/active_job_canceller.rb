class ActiveJobCanceller
  def self.cancel(job_id)
    ss = Sidekiq::ScheduledSet.new
    begin
      ss.find { |job| job.args[0]['job_id'] == job_id}.delete
    rescue
    end
  end
end 
