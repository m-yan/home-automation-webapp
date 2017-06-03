json.array!(@rooms) do |room|
  json.extract! room, :id, :to_s
end
