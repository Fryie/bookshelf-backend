Rails.application.routes.draw do
  resources :books, only: [:index]
  resources :book_requests, only: [:create]
end
