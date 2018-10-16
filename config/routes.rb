Rails.application.routes.draw do
  resources :books, only: [:index, :create]
  resources :book_requests, only: [:create]
end
