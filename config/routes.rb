Rails.application.routes.draw do
  devise_for :users
  root 'dashboard#admin'
  # get 'dashboard/admin'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
