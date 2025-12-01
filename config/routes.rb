Rails.application.routes.draw do
  mount ActiveDataFlow::Engine => "/active_data_flow"
  
  # ActiveDataFlow CRUD routes
  namespace :active_data_flow do
    resources :data_flows do
      member do
        patch :toggle_status
      end
      resources :data_flow_runs, only: [:index, :show, :create] do
        delete :purge, on: :collection
      end
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Application routes
  root "home#index"
  
  delete "reset", to: "home#reset", as: :reset
  
  resources :products
  resources :product_exports, only: [:index] do
    delete :purge, on: :collection
  end
  
  # DataFlow routes

  # By user thru UI
  get "data_flow", to: "active_data_flow/data_flow_runs#heartbeat_click", as: :heartbeat_click
  
  # By cron
  get "data_flow_event", to: "active_data_flow/data_flow_runs#heartbeat_event", as: :data_flow_event
end
