class HomeAutomationController < ApplicationController
  before_action :event_create, only: [:operate_tv, :operate_light, :operate_air, :update_enabled]
  before_action :set_at_home_flag, only: [:air, :tv, :light] 

  layout 'layouts/service'

  def air
    @page_header = "エアコン"
    device = Air.owned_by(current_user).first
    @temperature, @humidity = "-", "-"

    if device 
      @air_status = device.status || device.create_status
    else
      flash.now[:danger] = "操作可能なエアコンが登録されていません"
    end
  end

  def tv
    @page_header = "TV"
    @event_type_id = TV_EVENT_TYPE_ID
    @device = Tv.owned_by(current_user).first
    flash.now[:danger] = "操作可能なTVが登録されていません" if @device.nil?
  end

  def light
    @page_header = "照明"
    @event_type_id = LIGHT_EVENT_TYPE_ID
    @device = Light.owned_by(current_user).first
    flash.now[:danger] = "操作可能な照明が登録されていません " if @device.nil?
  end

  def automation_setting
    @page_header = "家電自動制御"
    @event_type_id = HA_EVENT_TYPE_ID 

    begin
      @sensors = MSensor.owned_by(current_user).order(:room_id).map { |sensor| sensor.build_remote_device }
    rescue => ex
      logger.fatal ex.message
      logger.fatal ex.backtrace.join("\n")
      flash.now[:danger] = "人感センサの状態取得時にエラーが発生しました"
    end

  end

  def renew_info
    @device = Device.find(params[:device_id]) 
    ret = get_environmental_info @device
    render 'renew_info_failure' if ret == false 
  end

  def operate_tv
    if WebUiEventHandler.new(@event).handle(event_params) 
      if params[:at_home_flag] == "true"
        head :ok 
      else
        render 'partials/success'
      end
    else
      render 'partials/failure'
    end
  end

  def operate_light
    result = WebUiEventHandler.new(@event).handle(event_params)

    if params[:at_home_flag] == "true"
      if result
        head :ok
      else
        render 'partials/failure'
      end
    else
      if result
        #HaRetryHandler.new(@event).handle

        render 'partials/success'
      else
        render 'partials/failure'
      end
    end
  end

  def operate_air
    @at_home_flag = params[:at_home_flag]
    @air_status = AirStatus.find(params[:id])

    result = HaAirWebUiEventHandler.new(@event).handle(@air_status, event_params)

    if params[:at_home_flag] == "true"
      if result
        render 'operate_air_at_home'
      else
        render 'operate_air_failure'
      end
    else
      if result
        #HaRetryHandler.new(@event).handle

        render 'operate_air'
      else
        render 'operate_air_failure'
      end
    end
  end

  def update_enabled
    if WebUiEventHandler.new(@event).handle(event_params)
      head :ok
    else
      head :ok
    end
  end


  private
    def event_create
      @event = Event.build_by_user(current_user)
      @event.event_type_id = params[:event_type_id] || AIR_EVENT_TYPE_ID
    end

    def set_at_home_flag
      @at_home_flag = House.ip_addresses.include?(request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip)
    end

    def event_params
      params.slice(:target_device_id, :remote_button_id, :air_status) 
    end 

    def get_environmental_info(device)
      case device.type
      when 'Air'
        begin
          @temperature = TSensor.nearby(device).first.build_remote_device.temperature.to_s
          @humidity = HSensor.nearby(device).first.build_remote_device.humidity.to_s
        rescue => ex
          logger.fatal ex.message
          logger.fatal ex.backtrace.join("\n")
          @temperature, @humidity = "-", "-"
          return false
        end
      when 'Light'
        begin
          @illuminance = ISensor.nearby(device).first.build_remote_device.illuminance.to_s
        rescue => ex
          logger.fatal ex.message
          logger.fatal ex.backtrace.join("\n")
          @illuminance = "-"
          return false
        end
      end
    end

end
