Rails.application.routes.draw do
  get "home/index"
  get "dashboard/show"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "home#index" # Set your root path

  get "/terms-of-service", to: "home#terms-of-service"
  get "/privacy-policy", to: "home#privacy-policy"

  # Define routes for user authentication
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/dashboard", to: "dashboard#show", as: "dashboard"
  delete "/logout", to: "sessions#destroy", as: "logout" # For logout functionality
end
