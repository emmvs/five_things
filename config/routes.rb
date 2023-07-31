Rails.application.routes.draw do
  devise_for :users

  root 'dashboard#index'
  resources :happy_things
  resources :users do
    resources :happy_things, only: %i[new create edit update destroy]
  end
end
