SecureUserModel::Application.routes.draw do
  get "/" => "index#index"
  get "/register" => "users#new"
  post "/register" => "users#new"
  get "/login" => "users#login"
  post "/login" => "users#login"
  get "/user" => "users#show"
  #TODO: add ability to edit user info.
  post "/user/0" => "users#destroy"
  get "/logout" => "sessions#destroy"
end
