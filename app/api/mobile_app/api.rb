require 'doorkeeper/grape/helpers'
require 'parallel'


class MobileApp::API < Grape::API
  format :json
  formatter :json, Grape::Formatter::Jbuilder

  helpers Doorkeeper::Grape::Helpers
  helpers do
    def current_resource_owner
      User.find_by id: doorkeeper_token.resource_owner_id if doorkeeper_token
    end
  end

  rescue_from RuntimeError, NameError, ActiveRecord::RecordNotFound do |e|
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    error! 'Server error', 500
  end

  before do
    doorkeeper_authorize!
  end

  AIR_OPERATION_TYPES = {
    power_on: 1,
    power_off: 2,
    mode_change: 5,
    temperature_change: 41,
    volume_change: 6,
    on_timer_set: 21,
    on_timer_30_set: 25,
    on_timer_60_set: 39,
    on_timer_unset: 22,
    off_timer_set: 23,
    off_timer_30_set: 26,
    off_timer_60_set: 40,
    off_timer_unset: 24,
    hot: 14,
    cold: 15,
    auto_on: nil,
    auto_off: nil
  }
  
  TV_OPERATION_TYPES = {
    power_switch: 8,
    volume_up: 9,
    volume_down: 10,
    channel_up: 11,
    channel_down: 12,
    channel_1: 27,
    channel_2: 28,
    channel_3: 29,
    channel_4: 30,
    channel_5: 31,
    channel_6: 32,
    channel_7: 33,
    channel_8: 34,
    channel_9: 35,
    channel_10: 36,
    channel_11: 37,
    channel_12: 38
  }
  
  LIGHT_OPERATION_TYPES = {
    power_on: 13,
    power_off: 20
  }


  resource :houses do
    route_param :id do
      do_not_route_head!
      do_not_route_options!

      before do
        if params[:id] == 'self'
          @house_id = current_resource_owner.house_id
        elsif params[:id]
          @house_id = params[:id]
          error! 'Not found', 404 unless House.exists? hgw_id: @house_id
          error! 'Forbidden', 403 if current_resource_owner.house_id != @house_id
        end
      end
      
      desc '機器配置ツリー取得API'
      get :rooms, jbuilder: 'houses/rooms' do
        @house = House.find(@house_id)
      end

      desc '監視モード取得API'
      get :monitoring_mode, jbuilder: 'houses/monitoring_mode' do
        hgw = Hgw.find_by!(house_id: @house_id)
        @mode = hgw.build_remote_device.mode
      end

      desc '監視状態取得API'
      get :monitoring_states, jbuilder: 'houses/monitoring_states' do
        devices = Device.where(type: ['Hgw', 'OcSensor', 'MSensor'], house_id: @house_id)
        remote_sensors = ThreadSafe::Array.new
        Parallel.each(devices, in_threads: 5) do |device|
          remote_device = device.build_remote_device
          case remote_device.type
          when 'Hgw'
            @mode = remote_device.mode
          else
            remote_sensors << remote_device
          end
        end
        @sensors = remote_sensors.map { |sensor| MonitoringSensor.new(sensor, @mode) }
      end

      desc '宅内情報サマリ取得API'
      get :summary, jbuilder: 'houses/summary' do
        living_room = Room.find_by house_id: @house_id, facility_type: 'living'
        devices = Device.where(type: ['Hgw', 'OcSensor', 'MSensor'], house_id: @house_id) + 
                  Device.where(type: ["TSensor", "HSensor", "ISensor"], room_id: living_room.id)
        Rails.logger.info devices.inspect
        remote_sensors = ThreadSafe::Array.new
        Parallel.each(devices, in_threads: 7) do |device| 
          remote_device = device.build_remote_device
          case device.type
          when 'Hgw'
            @mode = remote_device.mode
          when "TSensor"
            @temperature = remote_device.temperature
          when "HSensor"
            @humidity = remote_device.humidity
          when "ISensor"
            @illuminance = remote_device.illuminance
          when "OcSensor"
            remote_sensors << remote_device
          when "MSensor"
            remote_sensors << remote_device    
            @enabled = remote_device.enabled if device.room_id == living_room.id
          end
        end
        @sensors = remote_sensors.map { |sensor| MonitoringSensor.new(sensor, @mode) }
        @event = Event.where(['user_id = ? or ( house_id = ? and user_id is null )', current_resource_owner, current_resource_owner.house]).last
      end
      
      desc '監視モード更新API'
      params do
        requires :mode, type: Integer, allow_blank: false, values: 1..3
      end
      put :monitoring_mode do
        requester = Requester.new(current_resource_owner)
        requester.update_monitoring_mode House.find(@house_id), params[:mode]
        return NullJson
      end

      desc '一括操作API'
      params do
        requires :type, type: Integer, allow_blank: false, values: 1..3
      end 
      post :bulk_operation do
        requester = Requester.new(current_resource_owner)
        requester.operate_in_bulk params[:type] 
        status 200
        return NullJson
      end

    end
  end

  resource :rooms do
    route_param :id do
      do_not_route_head!
      do_not_route_options!

      before do
        @room_id = params[:id]
        if params[:id]
          error! 'id is invalid', 400 unless params[:id] =~ /\d+/ 
          error! 'Not found', 404 unless Room.exists? id: @room_id
          error! 'Forbidden', 403 if Room.find(@room_id).house_id != current_resource_owner.house_id
        end
      end

      desc '環境データ取得API'
      get :environmental_info, jbuilder: 'rooms/environmental_info' do
        devices = Device.where(type: ["TSensor", "HSensor", "ISensor"], room_id: @room_id)
        Parallel.each(devices, in_threads: 3) do |device|
          remote_device = device.build_remote_device
          case device.type
          when "TSensor"
            @temperature = remote_device.temperature
          when "HSensor"
            @humidity = remote_device.humidity
          when "ISensor"
            @illuminance = remote_device.illuminance
          end
        end
      end
    end
  end

  resource :users do
    route_param :user_id do
      do_not_route_head!
      do_not_route_options!

      before do
        if params[:user_id] == 'self'
          @user = current_resource_owner
          raise ActiveRecord::RecordNotFound if @user.blank?
        elsif params[:user_id]
          error! 'id is invalid', 400 unless params[:user_id] =~ /\d+/
          error! 'Not found', 404 unless User.exists? id: params[:user_id]
          error! 'Forbidden', 403 if current_resource_owner.id != params[:user_id]
          @user = User.find params[:user_id]
        end
      end

      desc '利用者取得API'
      get jbuilder: 'users/show.jbuilder' do
        @user
      end

      #desc '利用者更新API'
      #params do
      # requires :name, type: String, allow_blank: false
      #  requires :email, type: String, allow_blank: false
      #  requires :current_password, type: String, allow_blank: false
      #  optional :password, type: String, allow_blank: false
      #  optional :password_confirmation, type: String, allow_blank: false
      #end
      #put do
      #  user_params = ActionController::Parameters.new(params.to_hash)
      #                 .permit(:name, :email, :current_password, :password, :password_confirmation)        
      #  if @user.update_with_password user_params
      #    return NullJson
      #  else
      #    error! I18n.with_locale(:en) { @user.errors.full_messages }, 400
      #  end
      #end

      desc 'ライフログ取得API'
      resource :events do

        desc '一覧取得'
        params do
          optional :per_page, type: Integer, allow_blank: false, values: 1..100
          optional :page, type: Integer, allow_blank: false
          optional :event_type_id, type: Array[Integer], allow_blank: false, coerce_with: ->(val) { val.split(/\,+/).map(&:to_i) }, values: (1..13)
        end
        get '/', jbuilder: 'events/list.jbuilder' do
          per_page = params[:per_page] || 20
          error! 'id is invalid', 400 if params[:page] && params[:page] < 1
          page = params[:page] || 1
          if params[:event_type_id]
            @events = Event.owned_by(@user).where(event_type_id: params[:event_type_id]).page(page).per(per_page).order("id desc")
          else
            @events = Event.owned_by(@user).page(page).per(per_page).order("id desc")
          end
            @has_next = ! @events.last_page?
        end

        desc '1件取得'
        get '/:event_id', jbuilder: 'events/show.jbuilder' do
          error! 'id is invalid', 400 unless params[:event_id] =~ /\d+/
          error! 'Not found', 404 unless Event.exists? id: params[:event_id]
          @event = Event.find params[:event_id]
          unless @event.user_id == current_resource_owner.id || ( @event.user_id.blank?  && @event.house_id == current_resource_owner.house_id )
            error! 'Forbidden', 403
          end
          @event
        end
      end

    end
  end 

  resource :devices do
    route_param :id do
      do_not_route_head!
      do_not_route_options!

      before do
        if params[:id]
          error! 'id is invalid', 400 unless params[:id] =~ /\d+/
          error! 'Not found', 404 unless Device.exists? id: params[:id]
          @device = Device.find params[:id]
          error! 'Forbidden', 403 if @device.house_id != current_resource_owner.house_id
        end
        
      end

      desc '機器状態取得API'
      get jbuilder: 'devices/show.jbuilder' do
        case @device.type
        when 'Air'
          @device = @device.status || @device.create_status
        when 'MSensor'
          @device = @device.build_remote_device
        else
          error! "This device type (#{@device.type}) is outside the scope of this API ", 400
        end
      end

      desc '機器状態更新API'
      params do
        optional :operation_type, type: Symbol, allow_blank: false, coerce_with: ->(val) { val.to_sym}
        optional :mode, type: Integer, allow_blank: false, values: 1..5
        optional :temperature, type: Integer, allow_blank: false, values: 18..31
        optional :volume, type: Integer, allow_blank: false, values: 0..8
        optional :start_time, type: Time, allow_blank: false 
        optional :stop_time, type: Time, allow_blank: false 
        optional :enabled, type: String, allow_blank: false, values: ["true","false"]
      end
      put do
        case @device
        when Air,Tv,Light
          operation_type = params[:operation_type]
          error! "operation_type is missing", 400 if operation_type.blank?
          requester = Requester.new(current_resource_owner)
          case @device
          when Air
            error! "operation_type is invalid", 400 unless AIR_OPERATION_TYPES.keys.include? operation_type

            error! "mode is missing", 400        if operation_type == :mode_change && params[:mode].blank?
            error! "temperature is missing", 400 if operation_type == :temperature_change && params[:temperature].blank?
            error! "volume is missing", 400      if operation_type == :volume_change && params[:volume].blank?
            error! "start_time is missing", 400  if operation_type == :on_timer_set && params[:start_time].blank?
            error! "stop_time is missing", 400   if operation_type == :off_timer_set && params[:stop_time].blank?
           
            params[:start_time] = params[:start_time].to_s
            params[:stop_time] = params[:stop_time].to_s

            case operation_type
            when :auto_on
              requester.auto_on @device
            when :auto_off
              requester.auto_off @device
            else
              air_status_params = ActionController::Parameters.new(params).permit(:mode, :temperature, :volume, :start_time, :stop_time)
              requester.remote_control_for_air @device, AIR_OPERATION_TYPES[operation_type], air_status_params           
            end
          when Tv
            error! "operation_type is invalid", 400 unless TV_OPERATION_TYPES.keys.include? operation_type  
            requester.remote_control @device, TV_OPERATION_TYPES[operation_type] 
          when Light
            error! "operation_type is invalid", 400 unless LIGHT_OPERATION_TYPES.keys.include? operation_type
            requester.remote_control @device, LIGHT_OPERATION_TYPES[operation_type] 
          end
        when OcSensor, MSensor
          error! "enabled is missing", 400 unless params[:enabled]
          requester = Requester.new(current_resource_owner)

          if @device.instance_of?(MSensor) && headers['X-Used-For'] == 'SN'
            if params[:enabled] == "true"
              requester.enable @device, HA_SETTING_CHANGE_EVENT_TYPE_ID
            else
              requester.disable @device, HA_SETTING_CHANGE_EVENT_TYPE_ID
            end
          else             
            if params[:enabled] == "true"
              requester.enable @device
            else
              requester.disable @device
            end
          end
        else
          error! "This device type (#{@device.type}) is outside the scope of this API ", 400
        end
        return NullJson
      end 
    end 
  end

  #これより下には追記しない
  route :any, '*path' do
    error! 'Not found', 404
  end

end
