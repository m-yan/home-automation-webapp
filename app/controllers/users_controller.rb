class UsersController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
 
  prepend_before_filter :require_no_authentication, :only => [ :cancel]
  prepend_before_filter :authenticate_scope!, :only => [:index, :new, :create ,:edit, :update, :destroy]

  before_action :user_has_role_admin?

  # GET /accounts
  # GET /accounts.json
  def index
    @users = User.page(params[:page]).per(10).order(:id)
  end

  def show
    @user = User.find(params[:id])
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
   def create
     build_resource(sign_up_params)
     @user = resource
     if @user.save
       redirect_to @user, notice: 'User was successfully created.' 
     else
       render :new 
     end
   end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.' 
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def user_has_role_admin?
    if current_user && ! current_user.has_role?('admin')
      redirect_to :root , alert: '権限がありません'
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
