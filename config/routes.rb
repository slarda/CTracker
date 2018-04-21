require 'sidekiq/web'

Rails.application.routes.draw do

  # Active Admin routes ################################################################################################

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  authenticate :admin_user do
    mount Sidekiq::Web => '/admin/sidekiq'
    mount Redmon::App => '/admin/redmon'
  end

  # Authentication #####################################################################################################

  resources :user_sessions, only: [:new, :create, :destroy] do
    collection do
      get :forgot_password
    end
  end
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  get 'logout' => 'user_sessions#destroy'

  #get 'oauths/oauth'
  post 'oauth/callback' => 'oauths#callback'
  get 'oauth/callback' => 'oauths#callback' # for use with Github, Facebook
  get 'oauth/:provider' => 'oauths#oauth', :as => :auth_at_provider

  # Resources ##########################################################################################################

  resources :users,                 only: [:index, :show, :create, :update, :destroy] do
    collection do
      post :update_club
      post :update_team
      post :upload
      get :current
      get :unimpersonate
    end
    member do
      get :season_stats
      get :playing_career
      get :prior_games
      get :team_games
      get :impersonate
    end

    #resources :player_profiles, shallow: true, only: [:index]
    resources :player_equipment,   only: [:index, :create, :destroy], shallow: true
    resources :teams,               only: [:show]

    resource :awards
  end

  resources :associations,  only: [:index, :show, :create, :update, :destroy] do
    resources :clubs,       only: [:index], shallow: true
    resources :divisions,   only: [:index], shallow: true
    resources :users,       only: [:index], shallow: true

    collection do
      post :upload
    end
  end

  resources :clubs,         only: [:index, :show, :create, :update, :destroy] do
    resources :teams,       only: [:index], shallow: true
    resources :users,       only: [:index], shallow: true

    collection do
      post :upload
      get :import
      post :import
    end
  end

  resources :divisions,     only: [:show] do
    resources :teams,       only: [:index], shallow: true
  end

  resources :teams,         only: [:show, :create, :update, :destroy] do
    member do
      #get :last_results
      get :previous_meetings
    end

    collection do
      get :csv_upload
      post :csv_upload
      # get :previous_games
    end
  end
  #   member do
  #     get :subteams
  #   end
  # end

  resources :positions,     only: [:index]

  resources :equipment,     only: [:index] do
    collection do
      get :csv_upload
      post :csv_upload
    end
  end

  resources :brands,        only: [:index]
  resources :games,         only: [:show] do
    resources :player_results, only: [:index, :create, :update], shallow: true do
      collection do
        get :from_game
      end
    end
    member do
      get :weather_forecast
    end
  end

  resources :leagues,       only: [] do
    member do
      get :standings
    end
  end

  resources :player_results, only: [] do
    collection do
      get :from_games
    end
  end

  resources :articles, only: [:index, :show]


  # Static pages #######################################################################################################

  root 'static#index'
  get 'actions' =>  'static#actions'
  get 'dashboard' => 'static#dashboard'
  get 'static/login'
  #get 'content/*url' => 'static#content', format: false

end
