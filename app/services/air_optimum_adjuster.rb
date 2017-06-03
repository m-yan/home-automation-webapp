module AirOptimumAdjuster

  def self.process air
    t_sensor = TSensor.nearby(air).first
    h_sensor = HSensor.nearby(air).first

    get_temperature = Operation.new(operation_type_id: GET_TEMPERATURE_OPERATION_TYPE_ID, device: t_sensor)
    if get_temperature.send_request
      temperature = HgwIfParameters.build_from_xml(get_temperature.response).temperature
    end

    get_humidity = Operation.new(operation_type_id: GET_HUMIDITY_OPERATION_TYPE_ID, device: h_sensor)
    if get_humidity.send_request
      humidity = HgwIfParameters.build_from_xml(get_humidity.response).humidity
    end

    operations = [ get_temperature, get_humidity ]

    air_status = air.status || air.create_status

    info = EnvironmentalInfo.new temperature, humidity
    air_status.optimum_adjust_by info

    if air_status.changed?
      changed_properties = air_status.changed
      if changed_properties.include? 'power'
        if air_status.power
          remote_control = Operation.new(operation_type_id: AIR_POWER_ON_OPERATION_TYPE_ID, device: air)
        else
          remote_control = Operation.new(operation_type_id: AIR_POWER_OFF_OPERATION_TYPE_ID, device: air)
        end
      elsif changed_properties.include? 'mode'
        remote_control = Operation.new(operation_type_id: AIR_MODE_CHANGE_OPERATION_TYPE_ID, device: air)
      elsif changed_properties.include? 'temperature'
        remote_control = Operation.new(operation_type_id: AIR_SET_TEMPERATURE_OPERATION_TYPE_ID, device: air)
      end
      air_status.save
      remote_control.request %= { temperature: air_status.temperature.to_i, mode: air_status.mode, volume: air_status.volume }
      remote_control.send_request
      operations << remote_control
    end
    return operations
  end
end
