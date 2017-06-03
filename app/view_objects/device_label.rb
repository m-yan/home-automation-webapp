class DeviceLabel < ModelDecorator
  delegate :id, :house, :device_type, :room, :note, :id_at_hgw, to: :object, allow_nil: true

  def name
    label = device_type.name << "(" << room.to_s
    label <<  "_" << note if note.present?
    label << ")"
    return label
  end

  def location_only
    location = room.to_s
    location <<  "_" << note if note.present?
    return location
  end

  def self.build(devices)
    devices.each { |device| self.new(device) }
  end

end
