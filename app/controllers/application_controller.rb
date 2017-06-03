class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_action :authenticate_user!,  if: :use_authentication?
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :null_session
  before_action :prepare_params

  layout :default_or_sign_in

  protected

    def use_authentication?
      true
    end

    def user_has_role_admin?
      if current_user && ! current_user.has_role?('admin')
        redirect_to :root , alert: '対象リソースへのアクセスは許可されていません'
      end
    end

    def authenticate_digest
      authenticate_or_request_with_http_digest(DIGEST_REALM) do |username|
        DIGEST_USERS[username]
      end
    end

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_in) << [:name, :email, :house_id]
      devise_parameter_sanitizer.for(:sign_up) << [:name, :email, :house_id]
      devise_parameter_sanitizer.for(:account_update) << [:name, :email, :house_id]
    end

    def prepare_params
      if current_user && ! current_user.has_role?('admin')

        notifications = Notification.where(read: false, user: current_user)
        if notifications.nil?
          @notifications_count = nil
        else
          case notifications.count
          when 0
            @notifications_count = nil
          else
            @notifications_count = notifications.count
          end
        end
        
        @hires_url = "qdmora://store?path=%2f&qdid=" << ERB::Util.url_encode(current_user.house.id)
      end
    end

    def default_or_sign_in
      user_signed_in? ? 'application' : 'sign_in'
    end

end
