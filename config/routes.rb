Rails.application.routes.draw do
  devise_for :users

  root 'dashboard#index'
  resources :users do
    resources :things, only: %i[new create edit update destroy]
  end

  resources :things
  # get 'dashboard/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
