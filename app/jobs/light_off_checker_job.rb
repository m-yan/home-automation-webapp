class LightOffCheckerJob < LightRetryCheckerJob
  include ActiveJob::Retry
  constant_retry limit: DEFAULT_RETRY_LIMIT, delay: DELAULT_RETRY_DELAY

  def need_to_retry?(illuminance)
    logger.error "Need to retry. #{LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE} <= illuminance <= #{DAYLIGHT_CHECK_THRESHOLD_ILLUMINANCE}." if illuminance.between?(LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE, DAYLIGHT_CHECK_THRESHOLD_ILLUMINANCE)
    return illuminance.between?(LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE, DAYLIGHT_CHECK_THRESHOLD_ILLUMINANCE)
  end

end
