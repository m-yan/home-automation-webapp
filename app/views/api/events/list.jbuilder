json.events do
  json.array! @events do |event|
    json.extract! event, :id, :event_type_id
    json.event_type_desc event.event_type.description
    json.extract! event, :occurred_at
  end
end
json.has_next @has_next
