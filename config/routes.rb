Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :search, only: :index
      jsonapi_resources :venues
      #jsonapi_resources :gigs
    end
  end
end
