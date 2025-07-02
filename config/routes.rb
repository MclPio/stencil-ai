Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "/home", to: "pages#home"
  get "/privacy_policy", to: "pages#privacy_policy"
  get "/terms_of_use", to: "pages#terms_of_user"

  resource :registration, only: %i[ new create destroy edit update ]
  resources :invites, only: [ :index, :new, :create, :destroy ]

  resources :projects, only: %i[new create index update destroy] do
    member do
      patch :update_idea
    end

    resource :conversation, only: [ :show ]
  end

  resources :messages, only: [ :create ]
  get "/projects/:project_id/artifacts/:artifact_id", to: "conversations#artifact"
  resources :artifact_stencils, only: [ :new, :create, :show, :destroy ]
  resources :favorite_artifact_stencils, only: [ :index, :create, :destroy ]
end
