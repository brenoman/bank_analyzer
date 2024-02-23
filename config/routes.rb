# frozen_string_literal: true

Rails.application.routes.draw do
  get 'transactions/analyze'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'home#index'
  get '/merchant/:id', to: 'home#merchant', as: 'merchant'
  get '/user/:id', to: 'home#user', as: 'user'
  get '/device/:id', to: 'home#device', as: 'device'
  post '/ml/transactions/predict', to: 'transactions#predict'
  post '/ml/transactions/predictcb', to: 'transactions#predictcb'
  post '/um/transactions/predict', to: 'prediction#predict'
end
