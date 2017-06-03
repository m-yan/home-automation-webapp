json.rooms do
  json.array! @house.rooms.each do |room|
    json.extract! room, :id
    json.name room.to_s
    json.devices do
      json.array! room.devices do |device|
        json.extract! device, :id, :type
      end
    end
  end 
end
