class HgwSimController < ApplicationController
  before_action :set_device, :authenticate_digest, only: [:show, :update]
  before_action :user_has_role_admin?, only: [:event_generator, :devices, :event_create]

  def show
    head :bad_request if @device.blank?
    @device.create_status if @device.status.nil?
    begin 
      if ['Hgw', 'OcSensor', 'TSensor', 'HSensor', 'ISensor', 'MSensor'].include? @device.type
        render @device.type.underscore, status: :ok 
      else
        head :ok
      end
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      head :internal_server_error
    end
  end

  def update
    begin
      if ['Hgw', 'OcSensor', 'MSensor'].include? @device.type
        status = @device.status || @device.build_status
        status.update!(HgwIfParameters.build_from_hash(params).to_params)
      end
      head :ok
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      head :internal_server_error
    end
  end

  def event_generator
    @houses = House.all.order(:hgw_id)
    @event_types = EventType.order(:id).take(4)
    @page_header = "Event generator"
  end

  def devices 
    @devices = get_related_devices(params[:house_id],params[:event_type_id])
  end

  def event_create
    event = Event.new(event_params)
    event.occurred_at = Time.current
    event.device_id = Device.find(event.device_id).id_at_hgw

    http_client = HTTPClient.new
    http_client.set_auth(CLOUD_ENDPOINT, CLOUD_DIGEST_USER, CLOUD_DIGEST_PASSWORD)
    response = http_client.post(CLOUD_ENDPOINT, ERB.new(CREATE_EVENT_REQUEST_XML_TEMPLATE).result(binding), { 'Content-Type': 'application/xml; charset=utf-8' })

    case response.status.to_s
    when /^2/
      redirect_to :back, notice: 'success'
    else
      redirect_to :back, alert: 'failure'
    end
  end
 
  protected

    def use_authentication?
      ! request.format.xml?
    end

  private
    def set_device
      @device = Device.find_by(house_id: params[:hgw_id], id_at_hgw: params[:id_at_hgw])
    end

    def event_params
      params.require(:event).permit(:house_id, :device_id, :event_type_id)
    end

    def get_related_devices(house_id, event_type_id)
      case event_type_id.to_i
      when ROOM_IN_EVENT_TYPE_ID, ROOM_OUT_EVENT_TYPE_ID
        device_type = 'MSensor'
      when EMERGENCY_EVENT_TYPE_ID
        device_type = 'OcSensor'
      when E_BUTTON_EVENT_TYPE_ID
        device_type = 'EButton'
      end
      return DeviceLabel.build(Device.where(house_id: house_id, type: device_type))      
    end

    def authenticate_digest
      authenticate_or_request_with_http_digest(HGW_DIGEST_REALM) do |username|
        HGW_DIGEST_USERS[username]
      end
    end

    def log_header
      request.headers.sort.map { |k, v| logger.info "#{k}:#{v}" }
    end 

end
