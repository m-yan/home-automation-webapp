class HsWebUiEventHandler < WebUiEventHandler

  def handle(params)
    super(params) do |operation|
      operation.request %= { mode: params[:surveillance_mode] } if operation.operation_type_id == HS_MODE_CHANGE_OPERATION_TYPE_ID 
    end
    
  end

  def enable(sensors) 
    sensors.each do |sensor|
      @event.operations.new(operation_type: OperationType.find(HS_ENABLE_SENSOR_OPERATION_TYPE_ID), device: sensor).send_request
    end
    @event.save
  end


end 

