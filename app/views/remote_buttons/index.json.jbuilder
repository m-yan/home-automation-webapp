json.array!(@remote_buttons) do |remote_button|
  json.extract! remote_button, :id, :button_id, :operation_type_id, :order
  json.url remote_button_url(remote_button, format: :json)
end
