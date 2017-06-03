module WebUiEventHandlerAdaptor
    
  def self.remote_control(requester, target_device, ope_type)
    event = Event.build_by_user(requester) 
    case target_device
    when Tv
      event.event_type_id = TV_EVENT_TYPE_ID
    when Light
      event.event_type_id = LIGHT_EVENT_TYPE_ID
    else
      raise ArgumentError
    end
    params = {
               target_device_id: target_device.id,
               remote_button_id: ope_type
             }
    WebUiEventHandler.new(event).handle(params)
  end

  def self.remote_control_for_air(requester, target_device, ope_type, air_status_params)
    event = Event.build_by_user(requester)
    event.event_type_id = AIR_EVENT_TYPE_ID
    hash_params = {
               target_device_id: target_device.id,
               remote_button_id: ope_type,
               air_status: air_status_params
             }
    params = ActionController::Parameters.new(hash_params)
    air_status = target_device.status || target_device.create_status
    HaAirWebUiEventHandler.new(event).handle(air_status, params)
  end



  def self.update_monitoring_mode(requester, target_house, new_mode)
    target_hgw = Hgw.find_by house_id: target_house
    raise ActiveRecord::RecordNotFound if target_hgw.blank?    

    event = Event.new(house: target_house, user: requester, event_type_id: HS_EVENT_TYPE_ID)
    eh = HsWebUiEventHandler.new(event)
    params = { 
               target_device_id: target_hgw.id, 
               remote_button_id: 16, 
               surveillance_mode: new_mode
             }
    eh.handle params

    if (2..3).include? new_mode then
      oc_sensors = OcSensor.where(house: target_house).order(:room_id)
      eh.enable oc_sensors
    end
    if new_mode == 3 then
      m_sensors = MSensor.where(house: target_house).order(:room_id)
      eh.enable m_sensors
    end

  end

  def self.enable(requester, target_monitoring_sensor, event_type_id)
    self.change_sensor_enabled requester, target_monitoring_sensor, 18, event_type_id
  end

  def self.disable(requester, target_monitoring_sensor, event_type_id)
    self.change_sensor_enabled requester, target_monitoring_sensor, 19, event_type_id
  end

  private
    def self.change_sensor_enabled(requester, target_monitoring_sensor, remote_buttion_id, event_type_id)
      event = Event.build_by_user(requester)
      event.event_type_id = event_type_id
      eh = HsWebUiEventHandler.new(event)
      params = {
                 target_device_id: target_monitoring_sensor.id,
                 remote_button_id: remote_buttion_id,
               }
      eh.handle params
    end

end
