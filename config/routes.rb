Rails.application.routes.draw do
  get "age_consents/approve", to: 'age_consents#approve', as: :approve_age_consent
  get "age_consents/deny", to: 'age_consents#deny', as: :deny_age_consent
  get "organizations/index"
  get "organizations/show"
  get "organizations/new"
  get "organizations/create"
  get "organizations/edit"
  get "organizations/update"
  get "organizations/destroy"
  get "home/index"
  devise_for :users, controllers: { registrations: 'users/registrations' }
  root to: 'home#index'
  resources :organizations do
    resources :organization_members do
      post :transfer_ownership, on: :collection
    end
  end
  resource :age_participation, only: [:show]
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
