Rails.application.routes.draw do
  devise_for :users

  root "events#index"

  resource :dashboard, only: :show

  namespace :account do
    resource :profile, only: [:show, :update]
    resource :password, only: :update
  end

  resources :events, only: [:index, :show]
  get "explore", to: "events#explore", as: :explore_events
  resources :events, only: [] do
    resource :attendance, only: [:create, :update, :destroy]
  end

  namespace :organizer do
    resources :events do
      member do
        patch :submit
      end
    end
  end

  namespace :admin do
    resources :events, except: [:new, :create] do
      member do
        patch :publish
        patch :reject
        patch :cancel
      end
    end
  end

  get "faq", to: "pages#faq", as: :faq
  get "up" => "rails/health#show", as: :rails_health_check
end
