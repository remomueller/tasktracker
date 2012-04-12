Notes::Application.routes.draw do
  resources :comments do
    collection do
      get :search
    end
  end

  resources :frames

  resources :groups

  resources :project_users

  resources :projects do
    collection do
      post :selection
    end
    member do
      post :favorite
      post :visible
      post :colorpicker
    end
  end

  resources :stickies do
    collection do
      get :search
      get :template
      get :calendar
    end
    member do
      post :popup
      post :move
      post :complete
    end
  end

  resources :tags

  resources :templates do
    collection do
      post :add_item
      post :items
      post :selection
    end
    # member do
    #   post :generate_stickies
    # end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords' }, path_names: { sign_up: 'register', sign_in: 'login' }

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

  match "/about" => "sites#about", as: :about
  match "/settings" => "users#settings", as: :settings

  root to: "stickies#calendar"

  # See how all your routes lay out with "rake routes"
end
