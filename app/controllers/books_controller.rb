class BooksController < ApplicationController
  def index
    books = Book.all
    render json: books.to_json(only: [:title, :author, :isbn, :image_url, :status])
  end
end
