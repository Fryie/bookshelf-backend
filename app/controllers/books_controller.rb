class BooksController < ApplicationController
  def index
    books = Book.all
    render json: books.to_json
  end
end
