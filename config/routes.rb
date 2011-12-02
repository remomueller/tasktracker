Notes::Application.routes.draw do
  match '/contour' => 'contour/samples#index'

  match '/auth/failure' => 'contour/authentications#failure'
  match '/auth/:provider/callback' => 'contour/authentications#create'
  match '/auth/:provider' => 'contour/authentications#passthru'
  
  resources :authentications, :controller => 'contour/authentications'
  
  resources :comments do
    member do
      get :move
      post :move_update
      post :object_select
    end
    collection do
      get :search
      post :add_comment_table
      post :add_comment
    end
  end

  resources :frames

  resources :project_users

  resources :projects do
    collection do
      post :selection
    end
    member do
      post :favorite
    end
  end
  
  resources :stickies do
    collection do
      get :search
      get :template
    end
  end
  
  resources :templates do
    collection do
      post :add_item
    end
    member do
      post :generate_stickies
    end
  end
  
  devise_for :users, :controllers => {:registrations => 'contour/registrations', :sessions => 'contour/sessions', :passwords => 'contour/passwords'}, :path_names => { :sign_up => 'register', :sign_in => 'login' }

  resources :users do
    collection do
      post :search
      get :overall_graph
    end
    member do
      get :graph
      post :update_settings
    end
  end

  match "/about" => "sites#about", :as => :about
  match "/settings" => "users#settings", :as => :settings

  root :to => "projects#index"
  
  # See how all your routes lay out with "rake routes"
end
