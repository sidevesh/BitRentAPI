Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :items, only: [:show]
      post '/items/:id/accept', to: 'items#accept', as: 'item_accept'
      post '/items/:id/stop', to: 'items#stop', as: 'item_stop'
    end
  end
end