Rails.application.routes.draw do
  resources :release_types
  resources :editions
  resources :media
  resources :genres
  resources :phases
  resources :priorities
  resources :tags
  resources :playlists
  resources :artists
  resources :albums do
    member do
      put :edition_tracks
    end
  end
  resources :tracks


  get "/auth/status", to: "sessions#status"
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  match "/auth/:provider", to: "sessions#passthru", via: [ :get, :post ]
  get "/logout", to: "sessions#destroy"
  delete "/logout", to: "sessions#destroy"

  root to: "home#index"
  # end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
