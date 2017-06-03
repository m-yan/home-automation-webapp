class NotificationsController < ApplicationController
  before_action :set_notification, only: :update

  # GET /notifications
  # GET /notifications.json
  def index
    @page_header = "通知"
    unless params[:include_read]
      @notifications = Notification.where(read: false, user: current_user).page(params[:page]).per(10).order("id desc")
    else
      @notifications = Notification.where(user: current_user).page(params[:page]).per(10).order("id desc")
    end

    respond_to do |format|
      format.html
      format.js
    end

  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to :back, notice: 'Notification was successfully updated.' }
        format.js   { 
          @notifications = Notification.where(read: false, user: current_user).page(params[:page]).per(10).order(:id)
        }
      else
        format.html { redirect_to :back, alert: 'Failure.' }
      end
    end
  end

  def mark_all_as_read
    Notification.where(read: false, user: current_user).update_all(read: true)
    redirect_to action: :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:user_id, :message, :detect_device, :read)
    end
end
