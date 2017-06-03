class HomeSecurityController < ApplicationController
  before_action :event_create, only: [:update_mode, :update_enabled]

  layout 'layouts/service'

  def show
    @page_header = "自宅監視設定"
    begin
      @hgw = Hgw.owned_by(current_user).first.build_remote_device

      @sensors = OcSensor.owned_by(current_user).order(:room_id)
      @sensors += MSensor.owned_by(current_user).order(:room_id)
      @sensors = @sensors.map { |sensor| sensor.build_remote_device }
        
      flash.now[:danger] = "開閉センサが未登録のためサービスを利用できません" if @sensors.empty?
      
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      flash.now[:danger] = "HGWおよび開閉センサの状態取得時にエラーが発生しました"
    end
  end

  def renew_info
    begin
      @hgw = Hgw.owned_by(current_user).first.build_remote_device
      @sensors = OcSensor.owned_by(current_user).order(:room_id).map { |sensor| sensor.build_remote_device }
      @sensors += MSensor.owned_by(current_user).order(:room_id).map { |sensor| sensor.build_remote_device } 
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      head :internal_server_error
    end
  end

  def update_mode
    @hgw_id = params[:target_device_id]
    @mode = params[:surveillance_mode].to_i

    @oc_sensors = OcSensor.owned_by(current_user).order(:room_id)
    @m_sensors = MSensor.owned_by(current_user).order(:room_id)

    case @mode
    when 2
      @eh.enable @oc_sensors
    when 3
      @eh.enable @oc_sensors
      @eh.enable @m_sensors
    end
    @sensors = @oc_sensors + @m_sensors
    @sensors = @sensors.map { |sensor| sensor.build_remote_device }
  end

  def update_enabled
    @sensor = Device.find(params[:target_device_id]).build_remote_device
  end

  private 

    def event_create 
      @event = Event.build_by_user(current_user)
      @event.event_type_id = HS_EVENT_TYPE_ID

      @eh = HsWebUiEventHandler.new(@event)
      @eh.handle(event_params)
    end

    def event_params
      params.slice(:target_device_id, :remote_button_id, :surveillance_mode)
    end

end
