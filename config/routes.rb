Rails.application.routes.draw do
  root "events#index"
  resources :events do
    resource :attendance, only: [:create, :destroy]
    collection do
      get :explore
    end
  end
  devise_for :users

  namespace :admin do
    resources :events do
      member do
        post :approve
      end
      collection do
        get :pending
      end
    end
  end

  # Pages routes
  get 'faq', to: 'pages#faq', as: :faq
  get 'account', to: 'pages#account', as: :account
  put 'update_profile', to: 'pages#update_profile', as: :update_profile
  put 'update_password', to: 'pages#update_password', as: :update_password
  

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
