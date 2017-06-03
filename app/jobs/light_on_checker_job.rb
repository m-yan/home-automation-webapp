class LightOnCheckerJob < LightRetryCheckerJob
  include ActiveJob::Retry
  constant_retry limit: DEFAULT_RETRY_LIMIT, delay: DELAULT_RETRY_DELAY

  def need_to_retry?(illuminance)
    logger.error "Need to retry. illuminance <= #{LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE}." if illuminance <= LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE
    return illuminance <= LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE
  end
end
