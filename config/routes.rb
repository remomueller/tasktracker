# frozen_string_literal: true

Rails.application.routes.draw do
  root 'stickies#month'
  get '' => 'stickies#month', as: :dashboard

  scope module: :account do
    get :settings
    post :settings, action: :update_settings
    get :update_settings, to: redirect('settings')
    patch :change_password
    get :change_password, to: redirect('settings')
  end

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

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  namespace :project_preferences do
    post :favorite
    post :colorpicker
    patch :update
  end

  resources :project_users do
    member do
      post :resend
    end
    collection do
      get :accept
    end
  end

  get 'invite/:invite_token' => 'project_users#invite'

  resources :projects do
    collection do
      post :selection
    end
    member do
      get :bulk
      post :reassign
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

  devise_for :users, path_names: { sign_up: 'join', sign_in: 'login' }, path: ''

  resources :users

  scope module: :internal do
    get :search
    post :update_task_status
    post :toggle_tag_selection
    post :toggle_owner_selection
    post :toggle_project_selection
  end

  get '/day' => 'stickies#day', as: :day
  get '/week' => 'stickies#week', as: :week
  get '/month' => 'stickies#month', as: :month
  get '/tasks' => 'stickies#tasks', as: :tasks
end
