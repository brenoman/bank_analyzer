# frozen_string_literal: true

Rails.application.routes.draw do
  get 'transactions/analyze'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/ml/transactions/predict', to: 'transactions#predict'
  post '/ml/transactions/predictcb', to: 'transactions#predictcb'
  post '/um/transactions/predict', to: 'transactions#predictum'
end
