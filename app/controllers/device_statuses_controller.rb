class DeviceStatusesController < AdminApplicationController
  before_action :set_device_status, only: [:show, :edit, :update, :destroy]

  def index
    @page_header = type.titleize
    @device_statuses = device_status_class.all
  end

  def show
  end

  #def new
  #  @device_status = DeviceStatus.new
  #end

  def edit
  end

  #def create
  #  @device_status = DeviceStatus.new(device_status_params)
  #
  #  respond_to do |format|
  #    if @device_status.save
  #      format.html { redirect_to @device_status, notice: 'Device status was successfully created.' }
  #      format.json { render :show, status: :created, location: @device_status }
  #    else
  #      format.html { render :new }
  #      format.json { render json: @device_status.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  def update
    respond_to do |format|
      if @device_status.update(device_status_params)
        format.html { redirect_to @device_status, notice: 'Device status was successfully updated.' }
        format.json { render :show, status: :ok, location: @device_status }
      else
        format.html { render :edit }
        format.json { render json: @device_status.errors, status: :unprocessable_entity }
      end
    end
  end

  #def destroy
  #  @device_status.destroy
  #  respond_to do |format|
  #    format.html { redirect_to device_statuses_url, notice: 'Device status was successfully destroyed.' }
  #    format.json { head :no_content }
  #  end
  #end

  private
    def type
      @type = params[:type]
    end 

    def device_status_class
      type.camelize.constantize
    end 

    # Use callbacks to share common setup or constraints between actions.
    def set_device_status
      @device_status = device_status_class.find(params[:id])
      @page_header = type.titleize
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_status_params
      params.require(type.to_sym).permit(:device_id, :type, :power, :mode, :temperature, :volume, :on_timer, :start_time, :on_timer_job_id, :off_timer, :stop_time, :off_timer_job_id, :status, :enabled, :humidity, :illuminance)
    end
end
