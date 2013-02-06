TaskTracker::Application.routes.draw do

  mount MailPreview => 'mail_view' if Rails.env.development?

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

  resources :groups do
    collection do
      post :project_selection
    end
  end

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
      get :settings
      get :bulk
      post :reassign
      post :favorite
      post :visible
      post :colorpicker
    end
  end

  resources :stickies do
    collection do
      get :template
      get :calendar
      post :complete_multiple
      post :destroy_multiple
    end
    member do
      post :popup
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

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users do
    collection do
      post :search
      get :overall_graph
    end
    member do
      get :graph
      post :update_settings
      post :api_token
    end
  end

  match "/about" => "application#about", as: :about
  match "/about/use" => "application#use", as: :about_use
  match "/settings" => "users#settings", as: :settings
  match "/search" => "application#search", as: :search

  root to: "stickies#calendar"

  # See how all your routes lay out with "rake routes"
end
