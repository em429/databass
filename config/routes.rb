Rails.application.routes.draw do
  root 'home#index'
  
  resources :tracks do
    member do
      patch :toggle_favorite
    end
  end
  
  resources :playlists do
    resources :playlist_tracks, only: [:create, :destroy]
  end
  
  get 'favorites', to: 'favorites#index'
  
  # Search endpoint
  get 'search', to: 'tracks#search'
end
