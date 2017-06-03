Rails.application.routes.draw do

  use_doorkeeper do
    controllers :tokens => 'doorkeeper/custom_tokens'
  end

  mount MobileApp::API => '/api'

  resources :t_sensor_statuses, controller: :device_statuses, type: 't_sensor_status', only: [:index, :show, :edit, :update]
  resources :h_sensor_statuses, controller: :device_statuses, type: 'h_sensor_status', only: [:index, :show, :edit, :update]
  resources :i_sensor_statuses, controller: :device_statuses, type: 'i_sensor_status', only: [:index, :show, :edit, :update]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :remote_buttons
  resources :operation_details, only: :show, defaults: {format: :js}


  match 'ems/devices/:hgw_id/:id_at_hgw', to: 'hgw_sim#show', via: :get, defaults: {format: :xml}
  match 'ems/devices/:hgw_id/:id_at_hgw', to: 'hgw_sim#update', via: :post, defaults: {format: :xml}
  get 'hgw_sim/event_generator'
  get 'hgw_sim/devices'
  post 'hgw_sim/event_create'

  put 'notifications/mark_all_as_read', to: 'notifications#mark_all_as_read'
  resources :notifications, only: [:index, :update]
  resources :operation_types
  resources :houses do
    resources :rooms, only: :index
  end
  resources :devices

  resources :events, only: [:index, :show]
  post 'events', to: 'events#create', defaults: {format: :xml}, constraints: { port: '10080'}

  resources :event_types

  devise_for :users, only: [:session, :unlock]
  devise_scope :user do
    get 'users', to: 'users#index'
    post 'users', to: 'users#create', as: :new_registration
    get 'users/new', to: 'users#new', as: :new_user
    get 'users/edit', to: 'users/registrations#edit', as: :edit_user_registration
    get 'users/:id', to: 'users#show', as: :user
    patch 'users', to: 'users/registrations#update'
    put 'users', to: 'users/registrations#update', as: :user_registration
    delete 'users/:id', to: 'users#destroy'
  end

  get 'home/index'
  get 'home_automation/air'
  get 'home_automation/tv'
  get 'home_automation/light'
  get 'home_automation/automation_setting'
  get 'home_automation/renew_info/:device_id', to: 'home_automation#renew_info', as: :renew_info
  post 'home_automation/operate_air', defaults: {format: :js}
  post 'home_automation/operate_tv', defaults: {format: :js}
  post 'home_automation/operate_light', defaults: {format: :js}
  put 'home_automation/update_enabled', defaults: {format: :js}
  
  get 'home_security', to: 'home_security#show'
  get 'home_security/renew_info', to: 'home_security#renew_info', defaults: {format: :js}
  put 'home_security/update_mode', to: 'home_security#update_mode', defaults: {format: :js}
  put 'home_security/update_enabled', to: 'home_security#update_enabled', defaults: {format: :js}

  root to: "home#index"


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
