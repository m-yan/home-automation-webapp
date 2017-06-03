class HaAirWebUiEventHandler < WebUiEventHandler

  def handle(air_status, params)
    super(params) do |operation|
      case operation.operation_type_id
      when AIR_POWER_ON_OPERATION_TYPE_ID
        air_status.power = true
        air_status.auto = false
      when AIR_POWER_OFF_OPERATION_TYPE_ID
        air_status.power = false
        air_status.auto = false
      when AIR_TEMP_UP_OPERATION_TYPE_ID
        air_status.raise_temperature
        air_status.auto = false
      when AIR_TEMP_DOWN_OPERATION_TYPE_ID
        air_status.lower_temperature
        air_status.auto = false
      when AIR_MODE_CHANGE_OPERATION_TYPE_ID
        mode = params.require(:air_status).fetch(:mode)
        air_status.mode = mode if mode.present?
        air_status.auto = false
      when AIR_VOL_CHANGE_OPERATION_TYPE_ID
        volume = params.require(:air_status).fetch(:volume)
        air_status.volume = volume if volume.present?
        air_status.auto = false
      when AIR_TEMP_ADJUST_DOWN_OPERATION_TYPE_ID
        air_status.lower_temperature T_DELTA
        air_status.auto = false
      when AIR_TEMP_ADJUST_UP_OPERATION_TYPE_ID
        air_status.raise_temperature T_DELTA
        air_status.auto = false
      when AIR_ON_TIMER_SET_OPERATION_TYPE_ID
#        air_status.set_on_timer params.require(:air_status).values_at('start_time(4i)','start_time(5i)').join(':')
        start_time = params.require(:air_status).fetch(:start_time)
        air_status.set_on_timer start_time if start_time.present?

      when AIR_OFF_TIMER_SET_OPERATION_TYPE_ID
#        air_status.set_off_timer params.require(:air_status).values_at('stop_time(4i)','stop_time(5i)').join(':')
        stop_time = params.require(:air_status).fetch(:stop_time)
        air_status.set_off_timer stop_time if stop_time.present?

      when AIR_ON_TIMER_UNSET_OPERATION_TYPE_ID
        air_status.cancel_on_timer
      when AIR_OFF_TIMER_UNSET_OPERATION_TYPE_ID
        air_status.cancel_off_timer
      when GET_TEMPERATURE_OPERATION_TYPE_ID
        operation.send_request
        temperature = HgwIfParameters.build_from_xml(operation.response).temperature
        temperature = 18 if temperature < 18
        temperature = 31 if temperature > 31
        air_status.temperature = temperature
      when AIR_ON_TIMER_RELATIVE_SET30_OPERATION_TYPE_ID
        air_status.set_on_timer_relative 30
      when AIR_OFF_TIMER_RELATIVE_SET30_OPERATION_TYPE_ID
        air_status.set_off_timer_relative 30
      when AIR_ON_TIMER_RELATIVE_SET60_OPERATION_TYPE_ID
        air_status.set_on_timer_relative 60
      when AIR_OFF_TIMER_RELATIVE_SET60_OPERATION_TYPE_ID
        air_status.set_off_timer_relative 60
      when AIR_SET_TEMPERATURE_OPERATION_TYPE_ID
        temperature = params.require(:air_status).fetch(:temperature)
        air_status.temperature = temperature if temperature.present?
        air_status.auto = false
      end

      if air_status.save
        if operation.request
          operation.request %= { temperature: air_status.temperature.to_i, 
                                 mode: air_status.mode, 
                                 volume: air_status.volume, 
                                 start_time: AirStatusLabel.new(air_status).start_time_label,  
                                 stop_time: AirStatusLabel.new(air_status).stop_time_label, 
                                 start_time_relative: air_status.start_time_relative,
                                 stop_time_relative: air_status.stop_time_relative,
                                }
        end
      else
        return false
      end
    end
  end
end
