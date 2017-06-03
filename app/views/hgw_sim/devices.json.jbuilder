json.array!(@devices) do |device|
  json.extract! device, :id, :name
end
