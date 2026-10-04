Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :games, param: :name do
    # Public JSON API
    resources :scores, only: %i[ index create ], defaults: { format: :json }

    # Admin UI
    scope module: :games do
      resources :scores, only: :destroy
      resource :api_key, only: :update
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "games#index"
end
