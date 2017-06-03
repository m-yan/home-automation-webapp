class OperationTypesController < AdminApplicationController
  before_action :set_operation_type, only: [:show, :edit, :update, :destroy]

  # GET /operation_types
  # GET /operation_types.json
  def index
    @operation_types = OperationType.page(params[:page]).per(10).order(:id)
  end

  # GET /operation_types/1
  # GET /operation_types/1.json
  def show
  end

  # GET /operation_types/new
  def new
    @operation_type = OperationType.new
  end

  # GET /operation_types/1/edit
  def edit
  end

  # POST /operation_types
  # POST /operation_types.json
  def create
    @operation_type = OperationType.new(operation_type_params)

    respond_to do |format|
      if @operation_type.save
        format.html { redirect_to @operation_type, notice: 'Operation type was successfully created.' }
        format.json { render :show, status: :created, location: @operation_type }
      else
        format.html { render :new }
        format.json { render json: @operation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operation_types/1
  # PATCH/PUT /operation_types/1.json
  def update
    respond_to do |format|
      if @operation_type.update(operation_type_params)
        format.html { redirect_to @operation_type, notice: 'Operation type was successfully updated.' }
        format.json { render :show, status: :ok, location: @operation_type }
      else
        format.html { render :edit }
        format.json { render json: @operation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operation_types/1
  # DELETE /operation_types/1.json
  def destroy
    @operation_type.destroy
    respond_to do |format|
      format.html { redirect_to operation_types_url, notice: 'Operation type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation_type
      @operation_type = OperationType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operation_type_params
      params.require(:operation_type).permit(:description, :device_type, :method, :modules_body)
    end
end
