Rails.application.routes.draw do
  mount ActiveDataFlow::Engine => "/active_data_flow"
  
  # ActiveDataFlow CRUD routes
  namespace :active_data_flow do
    resources :data_flows do
      member do
        patch :toggle_status
      end
    end
    
    namespace :runtime do
      namespace :heartbeat do
        post "/data_flows/heartbeat", to: "data_flows#heartbeat", as: :heartbeat
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
  resources :products
  resources :product_exports, only: [:index] do
    delete :purge, on: :collection
  end
  
  # DataFlow routes
  get "data_flow", to: "data_flows#show", as: :data_flow
end
