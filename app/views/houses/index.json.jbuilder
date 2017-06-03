json.array!(@houses) do |house|
  json.extract! house, :id, :name, :ip_address
  json.url house_url(house, format: :json)
end
