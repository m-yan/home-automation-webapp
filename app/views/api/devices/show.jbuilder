case @device.type
when 'AirStatus'
  json.extract! @device, :auto, :power, :mode 
  json.temperature @device.temperature.to_i
  json.extract! @device, :volume, :on_timer
  json.start_time @device.start_time.strftime('%H:%M') if @device.on_timer == 3
  json.extract! @device, :start_time_relative if @device.on_timer == 4
  json.extract! @device, :off_timer
  json.stop_time @device.stop_time.strftime('%H:%M') if @device.off_timer == 3
  json.extract! @device, :stop_time_relative if @device.off_timer == 4
when 'MSensor'
  json.extract! @device, :enabled
end
