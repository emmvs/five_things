Rails.application.routes.draw do
  get 'things/index'
  get 'things/show'
  get 'things/new'
  get 'things/create'
  get 'things/edit'
  get 'things/update'
  get 'things/destroy'
  devise_for :users
  root 'dashboard#index'
  # get 'dashboard/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
