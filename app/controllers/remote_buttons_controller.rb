class RemoteButtonsController < AdminApplicationController
  before_action :set_remote_button, only: [:show, :edit, :update, :destroy]

  # GET /remote_buttons
  # GET /remote_buttons.json
  def index
    @remote_buttons = RemoteButton.all.order(:id).page(params[:page]).per(10)
  end

  # GET /remote_buttons/1
  # GET /remote_buttons/1.json
  def show
  end

  # GET /remote_buttons/new
  def new
    @remote_button = RemoteButton.new
  end

  # GET /remote_buttons/1/edit
  def edit
  end

  # POST /remote_buttons
  # POST /remote_buttons.json
  def create
    @remote_button = RemoteButton.new(remote_button_params)

    respond_to do |format|
      if @remote_button.save
        format.html { redirect_to @remote_button, notice: 'Remote button was successfully created.' }
        format.json { render :show, status: :created, location: @remote_button }
      else
        format.html { render :new }
        format.json { render json: @remote_button.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /remote_buttons/1
  # PATCH/PUT /remote_buttons/1.json
  def update
    respond_to do |format|
      if @remote_button.update(remote_button_params)
        format.html { redirect_to @remote_button, notice: 'Remote button was successfully updated.' }
        format.json { render :show, status: :ok, location: @remote_button }
      else
        format.html { render :edit }
        format.json { render json: @remote_button.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /remote_buttons/1
  # DELETE /remote_buttons/1.json
  def destroy
    @remote_button.destroy
    respond_to do |format|
      format.html { redirect_to remote_buttons_url, notice: 'Remote button was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_remote_button
      @remote_button = RemoteButton.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def remote_button_params
      params.require(:remote_button).permit(:note)
    end
end
