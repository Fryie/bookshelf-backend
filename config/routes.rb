Rails.application.routes.draw do
  resources :books, only: [:index, :create]

  resources :book_requests, only: [:create]

  resources :loans, only: [:create]
  delete :loans, to: "loans#destroy"
end
