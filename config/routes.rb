Rails.application.routes.draw do
  devise_for :users

  # Create a constraint to check if the user is logged in
  constraints ->(request) { request.env['warden'].user } do
    #              ☝🏻 current HTTP request object
    #                  Returns Raw Reck Env: Rack is a low-level interface between web servers that support Ruby and Ruby frameworks.
    #                          ☝🏻 Essentially, every Rails application is also a Rack application
    #                         .user fetches the currently authenticated user
    root 'dashboards#index', as: :authenticated_root
  end

  # If not authenticated, route to the home page
  root to: "pages#home"

  resources :happy_things

  get 'happy_things/:date', to: 'happy_things#show_by_date', as: :happy_things_by_date

  resources :friendships do
    post :change_status, on: :member
  end

  resources :dashboards, as: :dashboard do
    # get :retrieve_poem, on: :collection
  end
  # get 'dashboards/retrieve_poem', to: 'dashboards#retrieve_poem'
end
