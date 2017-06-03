json.extract! @event, :id, :event_type_id
json.event_type_desc @event.event_type.description
json.house_name @event.house_name
json.extract! @event, :occurred_at
json.user_name @event.user_name
json.detected_device_name @event.device_name
json.operations do
  json.array! @event.operations do |operation|
    json.operation_type_desc operation.operation_type_description
    json.target_device_name operation.device_name
    json.operated_at operation.created_at
  end
end
