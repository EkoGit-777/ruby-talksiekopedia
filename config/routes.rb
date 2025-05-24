Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get "/users", to: "users#index"
  post "/user", to: "users#create"
  get "/user", to: "users#show"

  get "/rooms", to: "rooms#index"
  post "/room", to: "rooms#create"
  get "/room/:name", to: "rooms#show"
end
