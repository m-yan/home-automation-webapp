class OperationDetailsController < ApplicationController
  def show
    @detail = OperationDetail.find(params[:id])
  end
end
