class Requester
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def remote_control(target_device, ope_type) #for TV/Light use
    raise ArgumentError unless target_device.is_a? Device

    WebUiEventHandlerAdaptor.remote_control(@user, target_device, ope_type)
  end

  def remote_control_for_air(target_device, ope_type, target_air_status)
    raise ArgumentError unless target_device.instance_of? Air

    WebUiEventHandlerAdaptor.remote_control_for_air(@user, target_device, ope_type, target_air_status)
  end

  def auto_on(air)
    event = Event.build_by_user @user
    event.event_type_id = AIR_EVENT_TYPE_ID
    event.operations.new(operation_type_id: AIR_AUTO_ON_OPERATION_TYPE_ID, device: air)
    event.save!
    status = air.status || air.create_status
    status.update(auto: true)
    AirAutoWorkerJob.perform_later air, event
  end

  def auto_off(air)
    event = Event.build_by_user @user
    event.event_type_id = AIR_EVENT_TYPE_ID
    event.operations.new(operation_type_id: AIR_AUTO_OFF_OPERATION_TYPE_ID, device: air)
    event.save
    status = air.status || air.create_status
    status.update(auto: false)
  end

  def update_monitoring_mode(target_house, new_mode)
    raise ArgumentError unless target_house.instance_of? House
    raise ArgumentError unless (1..3).include? new_mode
       
    WebUiEventHandlerAdaptor.update_monitoring_mode(@user, target_house, new_mode)  
  end

  def enable(target_monitoring_sensor, event_type_id=HS_EVENT_TYPE_ID)
    raise ArgumentError unless target_monitoring_sensor.instance_of? OcSensor or target_monitoring_sensor.instance_of? MSensor 
    WebUiEventHandlerAdaptor.enable(@user, target_monitoring_sensor, event_type_id)
  end

  def disable(target_monitoring_sensor, event_type_id=HS_EVENT_TYPE_ID)
    raise ArgumentError unless target_monitoring_sensor.instance_of? OcSensor or target_monitoring_sensor.instance_of? MSensor 
    WebUiEventHandlerAdaptor.disable(@user, target_monitoring_sensor, event_type_id)
  end

  def operate_in_bulk(type_id)
    event = Event.build_by_user @user

    air = Air.owned_by(@user).first
    light = Light.owned_by(@user).first
    hgw = Hgw.owned_by(@user).first

    if air
      air_status = air.status || air.create_status
      air_on = Operation.new(operation_type_id: AIR_POWER_ON_OPERATION_TYPE_ID, device: air)
      air_on.request %= { temperature: air_status.temperature.to_i, mode: air_status.mode, volume: air_status.volume }
      air_off = Operation.new(operation_type_id: AIR_POWER_OFF_OPERATION_TYPE_ID, device: air)
    end
    if light
      light_on = Operation.new(operation_type_id: LIGHT_ON_OPERATION_TYPE_ID, device: light)
      light_off = Operation.new(operation_type_id: LIGHT_OFF_OPERATION_TYPE_ID, device: light)
    end
    monitoring_mode_change = Operation.new(operation_type_id: HS_MODE_CHANGE_OPERATION_TYPE_ID, device: hgw)

    case type_id
    when 1 #外出
      event.event_type_id = GO_OUT_BO_EVENT_TYPE_ID
      air_status.try(:update, power: false)
      monitoring_mode_change.request %= { mode: 3 }
      tv = Tv.owned_by(@user).first
      music_stop = Operation.new(operation_type_id: MUSIC_PLAY_OPERATION_TYPE_ID, device: tv) if tv
      channel_up = Operation.new(operation_type_id: 34, device: tv) if tv
      operations = [ air_off, light_off, music_stop, channel_up, monitoring_mode_change ].compact
    when 2 #在宅
      event.event_type_id = GO_HOME_BO_EVENT_TYPE_ID
      air_status.try(:update, power: true)
      monitoring_mode_change.request %= { mode: 2 }
      operations = [ air_on, light_on, monitoring_mode_change ].compact
    when 3 #起床
      event.event_type_id = WAKE_UP_BO_EVENT_TYPE_ID
      air_status.try(:update, power: true)
      tv = Tv.owned_by(@user).first
      music_play = Operation.new(operation_type_id: MUSIC_PLAY_OPERATION_TYPE_ID, device: tv) if tv
      operations = [ air_on, light_on, music_play ].compact
    end

    operations.each do |operation|
      operation.send_request      
      sleep 0.5
    end
    event.operations << operations
    event.save
    return true
  end


end
