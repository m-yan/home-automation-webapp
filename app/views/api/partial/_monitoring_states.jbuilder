json.monitoring_mode mode
json.monitoring_sensors do
  json.array! sensors, :id, :type, :room_id, :location, :enabled, :sensed_state, :monitoring_state
end
