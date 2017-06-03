json.hems do
  json.forecast_charge 20529
  json.message "5529円使いすぎです"
end
json.home_automation do
  json.partial! 'partial/environmental_info', {temperature: @temperature, humidity: @humidity, illuminance: @illuminance}
end
json.home_security do
  json.partial! 'partial/monitoring_states', {mode: @mode, sensors: @sensors}
end
json.scene_select do
  json.enabled @enabled
end
json.life_log do
  json.event_type_desc @event.try(:event_type_description)
  json.occurred_at @event.try(:occurred_at)
end

