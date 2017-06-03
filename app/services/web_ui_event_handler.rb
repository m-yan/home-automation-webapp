class WebUiEventHandler
  attr_accessor :event

  def initialize(event)
    @event = event
  end

  def handle(params)
    target_device_id = params[:target_device_id]    
    remote_button_id = params[:remote_button_id]

    raise ArgumentError, "target_device_id is blank" if target_device_id.blank?
    raise ArgumentError, "remote_button_id is blank" if remote_button_id.blank? 

    device = Device.find(target_device_id)

    ret = nil
    RemoteButton.find(remote_button_id).operation_types.each do |operation_type|
      if operation_type.device_type && operation_type.device_type != device.type     
        device = operation_type.device_type.constantize.nearby(device).first
      end

      operation = @event.operations.new(operation_type: operation_type, device: device)
     
      yield(operation) if block_given?

      ret = operation.send_request
      break unless ret

    end

    if @event.save && ret
      return true
    else
      return false
    end
  end
end 
