class HgwIfParameters
  private_class_method :new

  def initialize(params)
    @params = params['Device']['Modules']
  end 

  def self.build_from_hash(params)
    return new(params)
  end

  def self.build_from_xml(xml)
    return new Hash.from_xml(xml)
  end

  def to_params
    params = {}
    params.store :mode, mode if mode = self.mode
    #params.store :temperature, temperature if temperature = self.temperature
    params.store :enabled, self.enabled unless self.enabled.nil?
    params.store :detected, self.detected unless self.detected.nil?
    return params
  end

  def mode
    begin
      @params['hgwDataPoints']['Data']['monitoringMode'].to_i
    rescue
      return nil
    end
  end 

  def temperature
    begin
      value = @params['temperatureSensorDataPoints']['Data']['measuredTemperatureValue'].to_f
      return value/10
    rescue
      return nil
    end
  end

  def humidity
    begin
      @params['humiditySensorDataPoints']['Data']['measuredValueOfRelativeHumidity'].to_i
    rescue
      return nil
    end
  end

  def enabled
    begin
      @params['operationStatus'] == 'true' ? true : false
    rescue
      return nil
    end
  end
 
  def opened
    begin
      @params['openCloseSensorDataPoints']['Data']['degreeOfOpeningDetectionStatus2'].to_i
    rescue
      return nil
    end
  end

  def illuminance
    begin
      @params['illuminanceSensorDataPoints']['Data']['measuredIlluminanceValue1'].to_i
    rescue
      return nil
    end
  end

  def detected
    begin
      @params['humanDetectionSensorDataPoints']['Data']['humanDetectionStatus'].to_i
    rescue
      return nil
    end
  end

end
