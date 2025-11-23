# frozen_string_literal: true

Rails.application.routes.draw do
  # Create a constraint to check if the user is logged in
  constraints ->(request) { request.env['warden'].user } do
    #              ☝🏻 current HTTP request object
    #                  Returns Raw Rack Env: Rack is a low-level interface between web servers that support Ruby and Ruby frameworks. # rubocop:disable Layout/LineLength
    #                          ☝🏻 Essentially, every Rails application is also a Rack application
    #                         .user fetches the currently authenticated user
    root 'dashboards#index', as: :authenticated_root
  end
  get 'future_root', to: 'happy_things#future_root'

  # If not authenticated, route to the home page
  root to: 'pages#home'

  # Users
  devise_for :users,
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks',
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }

  devise_scope :user do
    get 'settings', to: 'users/registrations#settings'
    patch 'settings', to: 'users/registrations#update'
  end
  resources :users, only: %i[index show]
  get 'friends', to: 'users#friends'
  get 'profile', to: 'users#profile'

  resource :user_config, only: %i[update]

  # Happy Things
  get 'happy_things/:date', to: 'happy_things#show_by_date', as: :happy_things_by_date,
                            constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  get 'happy_things/old_happy_thing', to: 'happy_things#old_happy_thing', as: :old_happy_thing
  post 'happy_things/old_happy_thing', to: 'happy_things#create_old_happy_thing'
  get 'calendar', to: 'happy_things#calendar'
  get 'friends/happy_things', to: 'happy_things#recent_happy_things'
  get 'through_the_years', to: 'happy_things#through_the_years'

  resources :happy_things, except: %i[index] do
    resources :comments, only: %i[create]
    collection do
      get :analytics
    end
  end

  resources :comments, only: %i[destroy]

  # Friendships
  resources :friendships, only: %i[create update destroy]

  # Poems
  # get 'dashboards/retrieve_poem', to: 'dashboards#retrieve_poem'
  resources :dashboards, as: :dashboard do
    # get :retrieve_poem, on: :collection
  end
end
