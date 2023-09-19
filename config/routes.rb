Rails.application.routes.draw do
  devise_for :users

  root 'dashboards#index'
  resources :happy_things

  resources :friendships do
    post :change_status, on: :member
  end


  resources :dashboards, as: :dashboard do
    # get :retrieve_poem, on: :collection
  end
  # get 'dashboards/retrieve_poem', to: 'dashboards#retrieve_poem'
end
