class RemoteDevice
  delegate :id, :room_id, :location, :type, to: :@device
  delegate :mode, :enabled, :temperature, :humidity, :opened, :detected, :illuminance, to: :@parameters
  def initialize(device)
    @device = device
    requestor = HgwIfRequestor.new(device.uri, :get)  

    if requestor.send_request
      @parameters = HgwIfParameters.build_from_xml(requestor.response) 
    else
      raise "Error"
    end
  end 
end
