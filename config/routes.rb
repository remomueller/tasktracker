Rails.application.routes.draw do
  resources :comments do
    collection do
      get :search
    end
  end

  resources :boards do
    member do
      post :archive
    end
    collection do
      post :add_stickies
    end
  end

  scope module: :external do
    get :about
    get '/about/use', action: 'use', as: :about_use
    get :version
  end

  resources :groups

  resources :project_users do
    collection do
      get :accept
    end
  end

  resources :projects do
    collection do
      post :selection
    end
    member do
      get :bulk
      post :reassign
      post :favorite
      post :visible
      post :colorpicker
    end
  end

  resources :stickies do
    collection do
      get :day
      get :week
      get :month
      get :template
    end
    member do
      post :move
      post :move_to_board
      post :complete
    end
  end

  resources :tags do
    collection do
      post :add_stickies
    end
  end

  resources :templates do
    collection do
      post :add_item
      post :items
      post :selection
    end
    member do
      get :copy
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }, path: ''

  resources :users do
    member do
      post :update_settings
    end
  end

  get '/settings' => 'users#settings', as: :settings
  get '/stats' => 'users#stats', as: :stats
  get '/search' => 'application#search', as: :search
  get '/day' => 'stickies#day', as: :day
  get '/week' => 'stickies#week', as: :week
  get '/month' => 'stickies#month', as: :month
  get '/tasks' => 'stickies#tasks', as: :tasks

  root to: 'stickies#week'
end
