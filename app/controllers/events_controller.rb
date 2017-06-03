class EventsController < ApplicationController
  before_action :set_event, only: [:show]
  before_action :authenticate_digest, only: [:create]

  # GET /events
  # GET /events.json
  def index
    user = current_user
    if user.has_role?('admin')
      @events = Event.page(params[:page]).per(10).order("id desc").includes(:event_type, :user)
    else 
      @events = Event.where(['user_id = ? or ( house_id = ? and user_id is null )', user, user.house]).
                     page(params[:page]).per(10).order("id desc").includes(:event_type, :user)
    end

    @page_header = "ライフログ"
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @page_header = "ライフログ"
    if current_user.has_role?('admin')
    elsif @event.user && @event.user != current_user || @event.house != current_user.house
      redirect_to action: :index
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.device = Device.find_by(house_id: @event.house_id, id_at_hgw: @event.device_id)

    head :unprocessable_entity and return if @event.device.nil? || (1..4).exclude?(@event.event_type_id.to_i)
    

    if @event.save
      case @event.event_type_id
      when ROOM_IN_EVENT_TYPE_ID
        HaRoomInEventHandlerJob.perform_later @event
      when ROOM_OUT_EVENT_TYPE_ID
        HaRoomOutEventHandlerJob.perform_later @event
      when EMERGENCY_EVENT_TYPE_ID, E_BUTTON_EVENT_TYPE_ID
        HsEventHandlerJob.perform_later @event
      end

      response.headers['Content-Location'] = "#{CSE_ID}/events/#{@event.id}"
      head :created
    else
      head :unprocessable_entity 
    end
  end
 
  protected
    def use_authentication?
      request.format.html?
    end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:cin).require(:con).permit(:hgw_id, :device_id, :event_type_id, :occurred_at)
    end
end
