Rails.application.routes.draw do
  root to: 'families#index'  # Adicione esta linha
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :needs
  resources :visits do
    collection do
      post 'search'
    end
    resources :members, only: [:new, :create]
    resources :needs, only: [:new, :create, :edit, :update, :destroy]
  end
  resources :regions
  resources :projects
  resources :members, except: [:new, :create]
  resources :families do
    collection do
      post 'search'
    end
    resources :members, only: [:new, :create, :edit, :update]
    resources :visits, only: [:new, :create, :edit, :update]
    resources :needs, only: [:new, :create, :edit, :update, :destroy]
  end
  resources :users
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
