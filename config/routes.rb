Rails.application.routes.draw do
  devise_for :users

  root 'dashboards#index'
  resources :happy_things, except: :index
  resources :dashboards, only: :index, as: :dashboard

  get 'get_poem_dashboard', to: 'dashboards#get_poem'
end
